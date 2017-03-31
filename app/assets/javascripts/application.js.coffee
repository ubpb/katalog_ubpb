#
# jquery and jquery_ujs have to come first
#
#= require jquery
#= require jquery.turbolinks
#= require jquery_ujs
#= require lodash
#= require polyfills

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

#= require_self
#= require trunker
#= require ./app/helpers/application_helper
#= require_tree ./app

Ractive.DEBUG = false;

Turbolinks?.enableProgressBar()

$(document).ready ->
  $("div[data-async-content] form").submit()

$(document).ready ->
  $('[data-toggle="popover"]').popover()
  $('[data-toggle="tooltip"]').tooltip()

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
