CustomEvents =
  bind: (element, eventName, handler) ->
    if element.addEventListener
      element.addEventListener eventName, handler, false
    else if element.attachEvent
      element[eventName] = 1
      element.attachEvent 'onpropertychange', (event) ->
        if event.propertyName is eventName
          handler()
    else
      throw new Error("Attempt to attach custom event #{eventName} to something which isn't a DOMElement")

  fire: (element, eventName) ->
    if element.addEventListener
      event = document.createEvent('HTMLEvents')
      event.initEvent(eventName, true, true)
      document.dispatchEvent(event)
    else if element.attachEvent
      if element[eventName]
        element[eventName]++
    else
      throw new Error("Attempt to fire custom event #{eventName} on something which isn't a DOMElement")


LiveReload =
  ExtVersion: '2.0.0'
  _hooked: no

  findScriptTag: ->
    for element in document.getElementsByTagName('script')
      if src = element.src
        if m = src.match /// /livereload\.js (?: \? (.*) )? $///
          return element
    null

  disable: (callback) ->
    element = @findScriptTag()
    if element
      CustomEvents.fire document, 'LiveReloadShutDown'
      element.parentNode.removeChild(element) if element.parentNode
    callback()

  enable: ({ useFallback, baseURI })->
    if useFallback
      url = "#{baseURI}livereload.js?ext=Safari&extver=#{LiveReload.ExtVersion}&host=localhost"
    else
      url = "http://localhost:35729/livereload.js?ext=Safari&extver=#{LiveReload.ExtVersion}"

    @hook()
    element = document.createElement('script')
    element.src = url
    document.body.appendChild(element)

  hook: ->
    return if @_hooked
    @_hooked = yes

    CustomEvents.bind document, 'LiveReloadConnect', =>
      safari.self.tab.dispatchMessage('status', { active: yes })
    CustomEvents.bind document, 'LiveReloadDisconnect', =>
      safari.self.tab.dispatchMessage('status', { active: no })


safari.self.addEventListener 'message', (event) ->
  # console.log ["LR event #{event.name} ", event.message]
  switch event.name
    when 'alert'
      alert event.message
    when 'enable'
      LiveReload.disable ->
        LiveReload.enable(event.message)
        safari.self.tab.dispatchMessage('status', { enabled: yes })
    when 'disable'
      LiveReload.disable ->
        safari.self.tab.dispatchMessage('status', { enabled: no })

safari.self.tab.dispatchMessage('status', { enabled: !!LiveReload.findScriptTag() })
