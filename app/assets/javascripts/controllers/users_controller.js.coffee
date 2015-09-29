#= require ./application_controller

(window.App ||= {}).UsersController ||= class extends window.App.ApplicationController
  @toggle_select_all: (event) ->
    target = $(event.target)

    checkboxes = target.closest("table").find("tbody input[type='checkbox']")
    checkboxes.each (index, el) =>
      $(el).prop("checked", target.prop("checked"))

  @toggle_select_mode: (event) ->
    event.preventDefault()
    $(".select-mode-control").toggleClass("hidden")
