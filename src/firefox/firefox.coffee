# Firefox does not use background/injected content separation, so this file
# serves the purpose of both global-firefox and injected-firefox.
{ LiveReloadGlobal, TabState } = require('../common/global')
{ LiveReloadInjected } = require('../common/injected')

findTabByContentDocument = (doc) ->
  for tab in gBrowser.tabs
    if gBrowser.getBrowserForTab(tab).contentDocument is doc
      return tab
  return null


LiveReloadInjected::send = (eventName, data) ->
  tab = findTabByContentDocument(@document)
  unless tab
    # TODO: we're inside an (I)FRAME. Is any special treatment needed?
    return

  switch eventName
    when 'status'
      LiveReloadGlobal.updateStatus(tab, data)
      ToggleButton.update()

TabState::send = (eventName, data={}) ->
  doc = gBrowser.getBrowserForTab(@tab).contentDocument
  injected = doc.__LiveReload_injected
  unless injected
    alert "There is no LiveReloadInjected for #{doc.location.href}"
    return

  switch eventName
    when 'alert'
      alert data
    when 'enable'
      injected.enable(data)
    when 'disable'
      injected.disable()

TabState::bundledScriptURI = -> 'chrome://livereload/content/livereload.js'

LiveReloadGlobal.isAvailable = (tab) -> yes

LiveReloadGlobal.initialize()


ToggleButton =
  initialize: ->
    @toggleButton = document.getElementById('livereload-button')
    @toggleButton.addEventListener 'command', (event) ->
      LiveReloadGlobal.toggle(gBrowser.selectedTab)
      ToggleButton.update()

  update: ->
    status = LiveReloadGlobal.tabStatus(gBrowser.selectedTab)
    @toggleButton.tooltiptext = status.buttonToolTip
    @toggleButton.image = "chrome://livereload/skin/#{status.buttonIcon}"


window.addEventListener 'load', ->
  ToggleButton.initialize()

    # alert "Hello from LiveReload!"
    # event.view.gBrowser.selectedTab

  ContentScriptInjectionSimulation =
    initialize: ->
      gBrowser.addEventListener 'DOMContentLoaded', (event) ->
        doc = event.originalTarget
        win = doc.defaultView
        return if doc?.location?.href is 'about:blank'
        # alert "Page loaded! #{doc?.location?.href}"

        doc.__LiveReload_injected = new LiveReloadInjected(doc, win, 'Firefox')

        win.addEventListener "unload", (event) ->
          doc.__LiveReload_injected = null
          # alert "Page unloaded #{doc.foo?.x}: #{doc.location.href}"

  ContentScriptInjectionSimulation.initialize()

  # window.addEventListener "pagehide", (event) ->
  #   if event.originalTarget instanceof HTMLDocument
  #     doc = event.originalTarget

  gBrowser.tabContainer.addEventListener 'TabSelect', (event) ->
    tab = event.target
    ToggleButton.update()
    # alert "Tab select:\nlabel = #{tab.label}\ndocument = #{tab.linkedBrowser?.contentDocument}\ndocument.href = #{tab.linkedBrowser?.contentDocument?.location?.href}"
  #     var index = livereloadBackground.pages.indexOf(tab);
  #     if (index == -1) {
  #         livereloadBackground.onDisablePage(tab);
  #     } else {
  #         livereloadBackground.onEnablePage(tab);
  #     }
  # }, false);

  gBrowser.tabContainer.addEventListener 'TabClose', (event) ->
    LiveReloadGlobal.killZombieTab event.target
    ToggleButton.update()
    # tab = event.target
    # console.error "Tab close:"
    # console.error tab
