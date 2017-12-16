require('../common/devtools')

class DevTools

  resourceAdded: (resource) ->
    console.log "LiveReload.resourceAdded: #{resource.url}"
    @send 'resourceAdded', url: resource.url

  resourceUpdated: (resource, content) ->
    console.log "LiveReload.resourceUpdated: %s - %s", resource.url, content
    @send 'resourceUpdated', url: resource.url, content: content


class FirefoxDevTools extends DevTools

  send: (message, data) ->
    firefox.runtime.sendMessage [message, data]


do ->

  devTools = new FirefoxDevTools()

  firefox.devtools.inspectedWindow.onResourceAdded.addListener (resource) ->
    devTools.resourceAdded(resource)

  firefox.devtools.inspectedWindow.onResourceContentCommitted.addListener (resource, content) ->
    devTools.resourceUpdated(resource, content)
