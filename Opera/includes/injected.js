/***
 *	Author: Gabrijel Gavranović  // gavro.nl
 *	CustomEvent & LiveReload objects/prototype function taken (and partially adapted) from:
 *  LiveReload Chrome & Firefox extentions, LiveReload.com & Nikita Vasilyev.
 *  See: http://help.livereload.com/kb/general-use/browser-extensions
 ***/

var tabId, CustomEvents, ExtVersion, LiveReloadInjected, liveReloadInjected;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
CustomEvents = {
  bind: function(element, eventName, handler) {
    if (element.addEventListener) {
      return element.addEventListener(eventName, handler, false);
    } else if (element.attachEvent) {
      element[eventName] = 1;
      return element.attachEvent('onpropertychange', function(event) {
        if (event.propertyName === eventName) {
          return handler();
        }
      });
    } else {
      throw new Error("Attempt to attach custom event " + eventName + " to something which isn't a DOMElement");
    }
  },
  fire: function(element, eventName) {
    var document, event;
    document = element instanceof window.HTMLDocument ? element : element.ownerDocument;
    if (element.addEventListener) {
      event = document.createEvent('HTMLEvents');
      event.initEvent(eventName, true, true);
      return document.dispatchEvent(event);
    } else if (element.attachEvent) {
      if (element[eventName]) {
        return element[eventName]++;
      }
    } else {
      throw new Error("Attempt to fire custom event " + eventName + " on something which isn't a DOMElement");
    }
  }
};
ExtVersion = '2.0.1';
LiveReloadInjected = (function() {
	function LiveReloadInjected(tabId, document, extName) {
		this.tabId = tabId;
		this.document = document;
		this.extName = extName;
	};
	LiveReloadInjected.prototype.doDisable = function() {
	  var element = this.document.getElementById('lr-script');
	  if (element) {
	    CustomEvents.fire(this.document, 'LiveReloadShutDown');
	    if (element.parentNode) {
	      element.parentNode.removeChild(element);
	    }
	  }
	  return;
	};
	LiveReloadInjected.prototype.doEnable = function(_arg) {
	  var element, scriptURI, url, useFallback;
	  useFallback = _arg.useFallback, scriptURI = _arg.scriptURI;
	  if (useFallback) {
	    url = "" + scriptURI + "?ext=" + this.extName + "&extver=" + ExtVersion + "&host=localhost";
	    console.log("Loading LiveReload.js bundled with the browser extension...");
	  } else {
	    url = "http://localhost:35729/livereload.js?ext=" + this.extName + "&extver=" + ExtVersion;
	    console.log("Loading LiveReload.js from " + (url.replace(/\?.*$/, '')) + "...");
	  }
	  element = this.document.createElement('script');
	  element.src = url;
	  element.id = "lr-script";
	  return this.document.getElementsByTagName('head')[0].appendChild(element);
	};
	LiveReloadInjected.prototype.disable = function() {
	  return this.doDisable(__bind(function() {
	    return this.send('status', {
	      enabled: false,
	      active: false
	    });
	  }, this));
	};
	LiveReloadInjected.prototype.enable = function(options) {
	  return this.doDisable(__bind(function() {
	    this.doEnable(options);
	    return this.send('status', {
	      enabled: true
	    });
	  }, this));
	};
	return LiveReloadInjected;
})();



window.addEventListener('DOMContentLoaded', function(event) {
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
	tabId = window.sessionStorage.getItem('tabId');
	opera.extension.postMessage({action: 'initConnection', tabid: tabId});
	
	opera.extension.onmessage = function(event){
		if(tabId == event.data.tabid || event.data.action.indexOf('Connection') > -1) {
			switch(event.data.action) {
				case 'setupConnection':
					//store your own ID, used for further communications (broadcastMessage is multicast only... :/)
					tabId = event.data.tabid;
					window.sessionStorage.setItem('tabId', event.data.tabid);
					liveReloadInjected = new LiveReloadInjected(event.data.tabid, document, 'Opera');
					break;
				case 'resumeConnection':
					if(event.data.state === 'active') {
						liveReloadInjected = new LiveReloadInjected(event.data.tabid, document, 'Opera');
						liveReloadInjected.doEnable({useFallback: false, scriptURI: ''});
					} else {
						liveReloadInjected = new LiveReloadInjected(event.data.tabid, document, 'Opera');
					}
					break;
				case 'enable':
					liveReloadInjected.doEnable({useFallback: false, scriptURI: ''});
					//can't call internal scripts (getFile function from extension does not exsist) @ Opera Extension
					//(or I just don't know how...)
					break;
				case 'disable':
					liveReloadInjected.doDisable();
					break;
			}
		}
	}
}, false);