$(document).ready ->
  # produces to heavy load, need to ease the resize event down to own
  #$(window).on 'resize', ->
  #  $('.trunker').trunker()

  $("[data-setup='trunker']")
  .trunker()
  .removeData("setup")
  .removeAttr("data-setup")
