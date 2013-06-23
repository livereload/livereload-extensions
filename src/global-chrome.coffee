
TabState::send = (message, data={}) ->
  chrome.tabs.sendRequest @tab, [message, data]

TabState::bundledScriptURI = -> chrome.extension.getURL('livereload.js')

LiveReloadGlobal.isAvailable = (tab) -> yes

LiveReloadGlobal.initialize()


ToggleCommand =
  invoke: ->
  update: (tabId) ->
    status = LiveReloadGlobal.tabStatus(tabId)
    chrome.browserAction.setTitle { tabId, title: status.buttonToolTip }
    chrome.browserAction.setIcon { tabId, path: { '19' : status.buttonIcon, '38' : status.buttonIconHiRes } }


chrome.browserAction.onClicked.addListener (tab) ->
  LiveReloadGlobal.toggle(tab.id)
  ToggleCommand.update(tab.id)

chrome.tabs.onSelectionChanged.addListener (tabId, selectInfo) ->
  ToggleCommand.update(tabId)

chrome.tabs.onRemoved.addListener (tabId) ->
  LiveReloadGlobal.killZombieTab tabId


chrome.extension.onRequest.addListener ([eventName, data], sender, sendResponse) ->
  # console.log "#{eventName}(#{JSON.stringify(data)})"
  switch eventName
    when 'status'
      LiveReloadGlobal.updateStatus(sender.tab.id, data)
      ToggleCommand.update(sender.tab.id)
    else
      LiveReloadGlobal.received(eventName, data)
