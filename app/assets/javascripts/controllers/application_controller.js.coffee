(window.App ||= {}).ApplicationController ||= class
  @prevent_default: (event) ->
    event.preventDefault()
