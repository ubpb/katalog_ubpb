ns = ((((window.App ||= {}).users ||= {}).watch_lists ||= {}).index ||= {})

ns.handle_toggle_select_all = (event) ->
  target = $(event.target)

  checkboxes = target.closest("tbody").find("input[type='checkbox']")
  checkboxes.not(checkboxes.last()).each (index, el) =>
    $(el).prop("checked", target.prop("checked"))

ns.handle_toggle_select_mode = (event) ->
  event.preventDefault()

  if($(".watch-lists-dropdown").hasClass("open"))
    $(".watch-lists-dropdown .dropdown-toggle").dropdown("toggle")

  $(".select-mode-control").toggleClass("hidden")
