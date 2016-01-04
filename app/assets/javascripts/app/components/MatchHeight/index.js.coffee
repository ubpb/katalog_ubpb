#= require app/Component
#= require matchHeight

do(app = (window.app ?= {})) ->
  (app.components ?= {}).MatchHeight = app.Component.extend
    oninit: ->
      reference = $(@get("reference") || $(@append).parent())
      $(@append).matchHeight(target: reference)
