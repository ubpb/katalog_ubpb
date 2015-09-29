((((window.App ||= {}).users ||= {}).hold_requests ||= {}).index ||= {})
.handle_toggle_select_mode = (event) ->
  event.preventDefault()

  if($(".hold-requests-dropdown").hasClass("open"))
    $(".hold-requests-dropdown .dropdown-toggle").dropdown("toggle")

  $(".delete-hold-request-control").toggleClass("hidden")
