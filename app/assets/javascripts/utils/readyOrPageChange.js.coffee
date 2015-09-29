window.app       ?= {}
window.app.utils ?= {}

window.app.utils.readyOrPageChange ?= (event_handler) =>
  # http://stackoverflow.com/questions/5574842/best-way-to-check-for-ie-less-than-9-in-javascript-without-library
  recentBrowser = window.document.addEventListener?

  # since Turbolinks 2.0.0 page:change is also triggered for the initial page load
  if window.Turbolinks && recentBrowser
    $(window).on('page:change', event_handler)
  else
    $.ready.promise().done(event_handler)
