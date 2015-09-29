(((window.app ?= {}).components ?= {}).HistogramFacet ?= class).LowerKeyInput = Ractive.extend
  isolated: false

  onrender: ->
    @on "keydown", (event) =>
      if event.original.which == 38
        @set("current_lower_key", parseInt(@get("current_lower_key")) + 1)
        false
      else if event.original.which == 40
        @set("current_lower_key", parseInt(@get("current_lower_key")) - 1)
        false

  template: "<input class='form-control' style='{{style}}' value='{{current_lower_key}}' on-keydown='keydown' on-keypress='keypress' />"
