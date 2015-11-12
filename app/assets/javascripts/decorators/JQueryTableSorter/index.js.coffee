$(document).ready ->
  $("table[data-setup='jquery-tablesorter']").each (index, element) ->
    $(element).tablesorter().removeAttr("data-setup")
