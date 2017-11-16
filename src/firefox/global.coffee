{ LiveReloadGlobal, TabState } = require('../common/global')

TabState::send = (message, data={}) ->
  browser.tabs.sendMessage @tab, [message, data]

TabState::bundledScriptURI = -> browser.runtime.getURL('livereload.js')

LiveReloadGlobal.isAvailable = (tab) -> yes

LiveReloadGlobal.initialize()


ToggleCommand =
  invoke: ->
  update: (tabId) ->
    status = LiveReloadGlobal.tabStatus(tabId)
    browser.browserAction.setTitle { tabId, title: status.buttonToolTip }
    browser.browserAction.setIcon { tabId, path: { '19' : status.buttonIcon, '38' : status.buttonIconHiRes } }


browser.browserAction.onClicked.addListener (tab) ->
  LiveReloadGlobal.toggle(tab.id)
  ToggleCommand.update(tab.id)

browser.tabs.onActivated.addListener (tabId, selectInfo) ->
  ToggleCommand.update(tabId)

browser.tabs.onRemoved.addListener (tabId) ->
  LiveReloadGlobal.killZombieTab tabId


browser.runtime.onMessage.addListener ([eventName, data], sender, sendResponse) ->
  # console.log "#{eventName}(#{JSON.stringify(data)})"
  switch eventName
    when 'status'
      LiveReloadGlobal.updateStatus(sender.tab.id, data)
      ToggleCommand.update(sender.tab.id)
    else
      LiveReloadGlobal.received(eventName, data)
