
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
    chrome.browserAction.setIcon { tabId, path: status.buttonIcon }


chrome.browserAction.onClicked.addListener (tab) ->
  matches = tab.url.match(/^https?\:\/\/([^\/?#]+)(?:[\/?#]|$)/i)
  domain = matches && matches[1]
  domain = domain.split(':')[0]
  LiveReloadGlobal.toggle(tab.id, domain)
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
