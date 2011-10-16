
LiveReloadInjected.send = (message, data) ->
  safari.self.tab.dispatchMessage message, data

safari.self.addEventListener 'message', (event) ->
  # console.log "#{event.name}(#{JSON.stringify(event.message)})"
  switch event.name
    when 'alert'
      alert event.message
    when 'enable'
      LiveReloadInjected.enable(event.message)
    when 'disable'
      LiveReloadInjected.disable()

LiveReloadInjected.initialize()
