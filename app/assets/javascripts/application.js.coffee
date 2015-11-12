#
# jquery and jquery_ujs have to come first
#
#= require jquery
#= require jquery.turbolinks
#= require jquery_ujs
#= require lodash

#
# turbolinks
#
#= require turbolinks

#
# translations
#
#= require i18n
#= require i18n/config
#= require i18n/translations

#
# all other javascript
#
#= require bootstrap-sprockets
#= require jquery-jsonp/src/jquery.jsonp
#= require jquery-tablesorter/extras/jquery.metadata
#= require jquery-tablesorter/jquery.tablesorter
#= require jquery-ui/slider
#= require jquery.ui.touch-punch
#= require bootstrap-simple-select
#= require ractive/ractive
#= require ractive-events-keys/ractive-events-keys
#= require trunker

#= require_tree ./components
#= require_tree ./decorators
#= require_tree ./utils

#= require ./polyfills/Array_reduce

Turbolinks?.enableProgressBar()

$(document).ready ->
  $("div[data-async-content] form").submit()

$(document).ready ->
  $("[data-decorator]").each (index, el) ->
    unless $(el).data("decorator-processed")
      decorator_class = $(el)
      .data("decorator")
      .split(".")
      .reduce(((memo, path_element) -> memo[path_element]), window)

      new decorator_class
        data: $(el).data("decorator-options")
        el: el

      $(el).data("deocrator-processed", true)

$(document).ready ->
  $("[data-same-height-as]").each (index, el) ->
    unless $(el).data("processed")
      resize_handler = ->
        if (reference_el = $($(el).data("same-height-as"))).length > 0
          $(el).css("height", reference_el.height())

      $(window).on "resize", resize_handler
      resize_handler()
      $(el).data("processed", true)

# fire up all components
$(document).ready ->
  $("[data-ractive-class]").each (index, placeholder) ->
    ractive_class = $(placeholder)
    .data("ractive-class")
    .split(".")
    .reduce(((memo, path_element) -> memo[path_element]), window)

    container = $(placeholder).parent()

    new ractive_class
      append: $(container).find(placeholder) # insert before placeholder
      data: $(placeholder).data("ractive-options")
      el: container
      partials:
        content: $(placeholder).text() if !!$(placeholder).text()
