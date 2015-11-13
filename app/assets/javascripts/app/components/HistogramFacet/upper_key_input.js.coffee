(((window.app ?= {}).components ?= {}).HistogramFacet ?= class).UpperKeyInput = Ractive.extend
  onrender: ->
    @on "keydown", (event) =>
      if event.original.which == 38
        @set("current_upper_key", parseInt(@get("current_upper_key")) + 1)
        false
      else if event.original.which == 40
        @set("current_upper_key", parseInt(@get("current_upper_key")) - 1)
        false

  template: "<input class='form-control' style='{{style}}' value='{{current_upper_key}}' on-keydown='keydown' on-keypress='keypress' />"
