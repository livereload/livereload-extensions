/***
 *	Author: Gabrijel Gavranović  // gavro.nl
 *	CustomEvent & LiveReload objects/prototype function taken (and partially adapted) from:
 *  LiveReload Chrome & Firefox extentions, LiveReload.com & Nikita Vasilyev.
 *  See: http://help.livereload.com/kb/general-use/browser-extensions
 ***/
 
//global vars/objects
/***
 * lrdata structure: tabID, status --> We should keep track of closed tab and remove them but can't get the ID
 * of the closed tabs! So let the object fill up, better a larger object instead of a periodical check of 
 * object agains all open tabs with extension.tabs.getAll()....
 ***/
var lrdata = {}; 

window.addEventListener("load", setupConnection, false);

function setupConnection() {
	var UIItemProperties = {
		disabled: true,
		title: "Please reload the page to be able to enable the LiveReload plugin.",
		icon: "images/IconDisabled.png",
		onclick: function(){
			toggleLiveReload(true);
		}
	};
	
	toggleButton = opera.contexts.toolbar.createItem(UIItemProperties);
	opera.contexts.toolbar.addItem(toggleButton);

	/***
	 * We need a sort of handshake communication: need to check and/or set current tab ID for things to work.
	 * Opera currently does not support an "onReload" function and neither is it possible to get the current tab id
	 * from the injected JS. From background.js it is not possible to any useful information (e.g. the tab ID) from 
	 * the connecting tab if it is not the focused tab (event object has limited data and tab/windows extension
	 * functionality is far from complete)!
	 * LiveReload reloads the entire tab if the page src (html) is edited, so background functionality is really needed.
	 * 
	 * Current workflow: (work-around), with added latency...):
	 * > [inject.js] send message on DOM ready with seesiondata: tabId (instead of onconnect @ background.js)
	 *   > [background.js] is tabId null or set? If set: resume state from own stored data. Null? New setup.
	 ***/

	/*opera.extension.onconnect = function(event) {
		var tab = opera.extension.tabs.getFocused();
		if(tab) {
			if(o.has(lrdata, tab.id) && lrdata[tab.id].state === 'active') {
				event.source.postMessage({action: 'resumeConnection', tabid: tab.id});
			} else {
				o.add(lrdata, tab.id, {state: 'inactive', timeStamp: event.timeStamp});
				event.source.postMessage({action: 'setupConnection', tabid: tab.id});
				
				toggleButton.disabled = false;
				toggleButton.title = 'Enable LiveReload';
			}
		} 
	}*/
	
	opera.extension.onmessage = function(event) {
		switch(event.data.action) {
			case "initConnection":
				if(event.data.tabid === null) {
					var tab = opera.extension.tabs.getFocused();
					o.add(lrdata, tab.id, {state: 'inactive'});
					event.source.postMessage({action: 'setupConnection', tabid: tab.id});
					toggleButton.disabled = false;
					toggleButton.title = 'Enable LiveReload';
				} else if(o.has(lrdata, event.data.tabid) && lrdata[event.data.tabid].state === 'active'){
					event.source.postMessage({action: 'resumeConnection', tabid: event.data.tabid, state: 'active'});
				} else {
					//event.source.postMessage({action: 'resumeConnection', tabid: event.data.tabid, state: 'inactive'});
					event.source.postMessage({action: 'setupConnection', tabid: event.data.tabid});
				}
				break;
		}
	}

	opera.extension.tabs.onfocus = function(event) {
		var tab = opera.extension.tabs.getFocused();
		if(tab) {
			if(!o.has(lrdata, tab.id)) {
				toggleButton.disabled = true;
				toggleButton.title = 'Please reload or even reopen the tab to be able to enable the LiveReload plugin.';
				toggleButton.icon = 'images/IconDisabled.png';
			} else {
				toggleButton.disabled = false;
				toggleLiveReload(event, false);
			}
		}
	}
}


function toggleLiveReload(change) {
	var tab = opera.extension.tabs.getFocused();
	if(tab) {
		if(o.has(lrdata, tab.id)) {
			switch(lrdata[tab.id].state) {
				case 'inactive':
					if(change === true) {
						opera.extension.broadcastMessage({action: 'enable', tabid: tab.id});
						lrdata[tab.id].state = 'active';
						toggleButton.icon = 'images/IconActive.png';
					} else {
						toggleButton.icon = 'images/IconDisabled.png';
					}
					break;
				case 'active':
					if(change === true){ 
						opera.extension.broadcastMessage({action: 'disable', tabid: tab.id});
						lrdata[tab.id].state = 'inactive';
						toggleButton.icon = 'images/IconDisabled.png';
					} else {
						toggleButton.icon = 'images/IconActive.png';
					}
					break;
			}
		}	
	}
}
