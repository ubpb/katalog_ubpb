#=require utils/createNestedObject
#=require utils/readyOrPageChange

# use it like app.utils.singletonReadyOrPageChange 'app.views.searches.show.setupCreationdateSlider', -> ...
unless (utils = app.utils.createNestedObject(window, 'app.utils')).singletonReadyOrPageChange
  utils.singletonReadyOrPageChange = (id, eventHandler) ->
    objectPath = id.replace(/\.\w*$/, '')
    objectId = if (positionOfFirstCharOfId = id.search(/\.(\w*)$/)) > -1 then id.slice(positionOfFirstCharOfId + 1, -1) else null

    parentObject = app.utils.createNestedObject(window, objectPath)

    unless parentObject[objectId]
      parentObject[objectId] = eventHandler
      app.utils.readyOrPageChange(parentObject[objectId])
