#=require utils/singletonReadyOrPageChange

app.utils.singletonReadyOrPageChange 'app.views.application.setupPermalinkPopovers', ->
  # initialize permalink popovers and register event handler
  $('.permalink-popover').popover().on 'click', (e) ->
    # in case this a href, prevent the link from beeing triggere
    e.preventDefault()
    # and select the textarea text
    $(e.currentTarget).siblings().find('input').select()
