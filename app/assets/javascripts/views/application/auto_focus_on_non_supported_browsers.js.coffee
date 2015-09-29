#= require utils/singletonReadyOrPageChange

# Enable support for autofocus attribute for non supported browser
app.utils.singletonReadyOrPageChange 'app.views.application.autoFocusOnNonSupportedBrowsers', ->
  $('input[autofocus]:first').focus()
