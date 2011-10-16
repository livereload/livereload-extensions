
LiveReloadInjected.send = (message, data) ->
  chrome.extension.sendRequest [message, data]

chrome.extension.onRequest.addListener ([eventName, data], sender, sendResponse) ->
  # console.log "#{eventName}(#{JSON.stringify(data)})"
  switch eventName
    when 'alert'
      alert data
    when 'enable'
      LiveReloadInjected.enable(data)
    when 'disable'
      LiveReloadInjected.disable()

LiveReloadInjected.initialize()
