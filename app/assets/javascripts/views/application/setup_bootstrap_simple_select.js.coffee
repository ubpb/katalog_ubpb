$(document).ready ->
  $("[data-setup='bootstrap-simple-select']")
  .bootstrapSimpleSelect()
  .removeData("setup")
  .removeAttr("data-setup")

  # Fix for #4550 - Button dropdown links don't work on mobile (android, iOS)
  # https://github.com/twitter/bootstrap/issues/4550#issuecomment-8476763
  $(".dropdown-menu").on "touchstart.dropdown.data-api", (e) ->
    e.stopPropagation()
