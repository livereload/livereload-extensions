
LiveReloadInjected::send = (message, data) ->
  chrome.runtime.sendMessage [message, data]

liveReloadInjected = new LiveReloadInjected(document, window, 'Chrome')

chrome.runtime.onMessage.addListener ([eventName, data], sender, sendResponse) ->
  # console.log "#{eventName}(#{JSON.stringify(data)})"
  switch eventName
    when 'alert'
      alert data
    when 'enable'
      liveReloadInjected.enable(data)
    when 'disable'
      liveReloadInjected.disable()
