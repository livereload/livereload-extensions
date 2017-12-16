{ LiveReloadInjected } = require('../common/injected')

LiveReloadInjected::send = (message, data) ->
  browser.runtime.sendMessage [message, data]

liveReloadInjected = new LiveReloadInjected(document, window, 'Firefox')

browser.runtime.onMessage.addListener ([eventName, data], sender, sendResponse) ->
  # console.log "#{eventName}(#{JSON.stringify(data)})"
  switch eventName
    when 'alert'
      alert data
    when 'enable'
      liveReloadInjected.enable(data)
    when 'disable'
      liveReloadInjected.disable()
