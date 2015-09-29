#= require ./application_controller

SearchesController = (window.App ||= {}).SearchesController ||= class extends window.App.ApplicationController
  @handle_user_watch_list_entry_created: (event, entry) ->
    debugger


$(window).off(".SearchesController")
$(window).on(
  "app:user:watch_list:entry:created.SearchesController",
  SearchesController.handle_user_watch_list_entry_created
)
