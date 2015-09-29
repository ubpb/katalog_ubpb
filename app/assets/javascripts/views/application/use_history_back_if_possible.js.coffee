events_namespace = "use_history_back_if_possible"

# unregister all event handlers
$(document).off ".#{events_namespace}"

# register Turbolinks page:before-change handler to track last url
$(document).on "page:before-change.#{events_namespace}", (e) ->
  app.url_before_page_change = location.toString()

$(document).on "click.#{events_namespace}", "[data-use-history-back-if-possible]", (e) ->
  if app.url_before_page_change == e.currentTarget.href
    e.preventDefault()
    e.stopPropagation()
    history.back()
