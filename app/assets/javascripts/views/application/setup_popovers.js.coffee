#= require utils/singletonReadyOrPageChange

app.utils.singletonReadyOrPageChange 'app.views.application.setupPopovers', ->
  $('[rel="popover"]').popover()

  $(document).ajaxComplete (e) ->
    $('[rel="popover"]').popover()

  $(document).on 'click', 'a[rel="popover"]', (e) ->
    e.preventDefault()
