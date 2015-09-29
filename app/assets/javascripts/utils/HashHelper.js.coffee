#= require polyfills/Array_indexOf

window.app       = {} if not window.app
window.app.utils = {} if not window.app.utils

window.app.utils.HashHelper = class
  @indexOfByKeyValue: (arr, key, value) ->
    for elem in arr
      if elem[key] is value then return arr.indexOf(elem)
    return -1
