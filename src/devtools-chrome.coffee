
class DevTools

  resourceAdded: (resource) ->
    console.log "LiveReload.resourceAdded: #{resource.url}"
    @send 'resourceAdded', url: resource.url

  resourceUpdated: (resource, content) ->
    console.log "LiveReload.resourceUpdated: %s - %s", resource.url, content
    @send 'resourceUpdated', url: resource.url, content: content


class ChromeDevTools extends DevTools

  send: (message, data) ->
    chrome.runtime.sendMessage [message, data]


do ->

  devTools = new ChromeDevTools()

  chrome.devtools.inspectedWindow.onResourceAdded.addListener (resource) ->
    devTools.resourceAdded(resource)

  chrome.devtools.inspectedWindow.onResourceContentCommitted.addListener (resource, content) ->
    devTools.resourceUpdated(resource, content)
