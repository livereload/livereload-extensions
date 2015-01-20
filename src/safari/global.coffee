{ LiveReloadGlobal, TabState } = require('../common/global')

TabState::send = (message, data={}) ->
  @tab.page.dispatchMessage message, data

TabState::bundledScriptURI = -> safari.extension.baseURI + 'livereload.js'

LiveReloadGlobal.isAvailable = (tab) -> !!tab.url

LiveReloadGlobal.initialize()


Commands =
  toggle:
    invoke: (event) ->
      LiveReloadGlobal.toggle(event.target.browserWindow.activeTab)
      event.target.validate()
    validate: (event) ->
      @toolbarItem = event.target
      LiveReloadGlobal.killZombieTabs()

      status = LiveReloadGlobal.tabStatus(event.target.browserWindow.activeTab)
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
  # console.log "#{event.name}(#{JSON.stringify(event.message)})"
  switch event.name
    when 'status'
      LiveReloadGlobal.updateStatus(event.target, event.message)
      Commands.toggle.revalidate()
