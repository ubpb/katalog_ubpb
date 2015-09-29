#= require utils/singletonReadyOrPageChange

app.utils.singletonReadyOrPageChange 'app.views.application.setupBootstrapSwitch', ->
  $("[data-setup='bootstrap-switch']")
  .bootstrapSwitch()
  .removeData("setup")
  .removeAttr("data-setup")
