{ LiveReloadInjected } = require('../common/injected')

LiveReloadInjected::send = (message, data) ->
  safari.self.tab.dispatchMessage message, data

liveReloadInjected = new LiveReloadInjected(document, window, 'Safari')

safari.self.addEventListener 'message', (event) ->
  # console.log "#{event.name}(#{JSON.stringify(event.message)})"
  switch event.name
    when 'alert'
      alert event.message
    when 'enable'
      liveReloadInjected.enable(event.message)
    when 'disable'
      liveReloadInjected.disable()
