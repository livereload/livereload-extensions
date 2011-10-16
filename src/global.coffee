
Status =
  unavailable:
    buttonEnabled: no
    buttonToolTip: 'LiveReload not available on this tab'
    buttonIcon: 'IconUnavailable.png'
  disabled:
    buttonEnabled: yes
    buttonToolTip: 'Enable LiveReload'
    buttonIcon: 'IconDisabled.png'
  enabled:
    buttonEnabled: yes
    buttonToolTip: 'LiveReload is connecting, click to disable'
    buttonIcon: 'IconEnabled.png'
  active:
    buttonEnabled: yes
    buttonToolTip: 'LiveReload is connected, click to disable'
    buttonIcon: 'IconActive.png'



class TabState
  constructor: (@tab) ->
    @enabled = no
    @active  = no

  isAlive: -> !!@tab.url

  enable: (useFallback) ->
    @tab.page.dispatchMessage 'enable', { useFallback, baseURI: safari.extension.baseURI }

  disable: ->
    @tab.page.dispatchMessage 'disable'

  updateStatus: (status) ->
    if status.enabled?
      @enabled = status.enabled
    if status.active?
      @active = status.active

  status: ->
    switch
      when @active
        Status.active
      when @enabled
        Status.enabled
      else
        Status.disabled

  alert: (message) ->
    @tab.page.dispatchMessage 'alert', message


if navigator.userAgent.match(/Mac OS X/)
  CannotConnectAlert = """Could not connect to LiveReload server. Please make sure that LiveReload 2 (or another compatible server) is running."""
else
  CannotConnectAlert = """Could not connect to LiveReload server. Please make sure that a compatible LiveReload server is running. (We recommand guard-livereload, until LiveReload 2 comes to your platform.)"""

LiveReload =
  _tabs: []

  killZombieTabs: ->
    @_tabs = (tabState for tabState in @_tabs when tabState.isAlive())

  findState: (tab, create=no) ->
    for tabState in @_tabs
      return tabState if tabState.tab is tab
    if create
      state = new TabState(tab)
      @_tabs.push state
      state
    else
      null

  isAvailable: (tab) ->
    !!tab.url

  toggle: (tab) ->
    console.log "toggle"
    if @isAvailable(tab)
      state = @findState(tab, yes)
      if state.enabled
        state.disable()
        unless @areAnyTabsEnabled()
          @afterDisablingLast()
      else
        if @areAnyTabsEnabled()
          console.log "enabling 2nd+"
          state.enable(@useFallback)
        else
          console.log "before 1st"
          @beforeEnablingFirst (err) =>
            if err
              switch err
                when 'cannot-connect' then state.alert(CannotConnectAlert)
                when 'cannot-download' then state.alert("Cannot download livereload.js")
            else
              state.enable(@useFallback)

  tabStatus: (tab) ->
    unless @isAvailable(tab)
      return Status.unavailable
    @findState(tab)?.status() || Status.disabled

  updateStatus: (tab, status) ->
    @findState(tab, yes).updateStatus(status)

  areAnyTabsEnabled: ->
    return yes for tabState in @_tabs when tabState.enabled
    no

  beforeEnablingFirst: (callback) ->
    @useFallback = no
    # probe using web sockets
    ws = new WebSocket("ws://localhost:35729/livereload")
    ws.onerror = =>
      callback('cannot-connect')
    ws.onopen = =>
      ws.send JSON.stringify({ command: 'hello', protocols: 'http://livereload.com/protocols/connection-check-1' })
    ws.onmessage = (event) =>
      console.log "Incoming message: #{event.data}"
      if event.data.match(/^!!/)
        @useFallback = yes
        callback(null)
        ws.close()
      else if event.data.match(/^\{/)
        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = =>
          if xhr.readyState is XMLHttpRequest.DONE and xhr.status is 200
            @script = xhr.responseText
            callback(null)
        xhr.onerror = (event) =>
          callback('cannot-download')
        xhr.open("GET", "http://localhost:35729/livereload.js", true)
        xhr.send(null)


  afterDisablingLast: ->


Commands =
  toggle:
    invoke: (event) ->
      LiveReload.toggle(event.target.browserWindow.activeTab)
      event.target.validate()
    validate: (event) ->
      @toolbarItem = event.target
      LiveReload.killZombieTabs()

      status = LiveReload.tabStatus(event.target.browserWindow.activeTab)
      event.target.disabled = !status.buttonEnabled
      event.target.toolTip  = status.buttonToolTip
      event.target.image    = safari.extension.baseURI + status.buttonIcon

    revalidate: ->
      @toolbarItem?.validate()


safari.application.addEventListener 'command', (event) ->
  Commands[event.command]?.invoke?(event)

safari.application.addEventListener 'validate', (event) ->
  Commands[event.command]?.validate?(event)

safari.application.addEventListener 'message', (event) ->
  switch event.name
    when 'status'
      LiveReload.updateStatus(event.target, event.message)
      Commands.toggle.revalidate()
