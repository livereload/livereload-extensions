
LiveReloadInjected::send = (message, data) ->
  chrome.extension.sendRequest [message, data]

liveReloadInjected = new LiveReloadInjected(document)

chrome.extension.onRequest.addListener ([eventName, data], sender, sendResponse) ->
  # console.log "#{eventName}(#{JSON.stringify(data)})"
  switch eventName
    when 'alert'
      alert data
    when 'enable'
      liveReloadInjected.enable(data)
    when 'disable'
      liveReloadInjected.disable()
