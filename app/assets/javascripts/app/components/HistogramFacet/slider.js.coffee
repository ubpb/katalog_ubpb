(((window.app ?= {}).components ?= {}).HistogramFacet ?= class).Slider = Ractive.extend
  onrender: ->
    #
    # create slider
    #
    slider = $(@el).find(".cat-histogram-facet-slider").slider
      range: true,
      min: @get("min_key"),
      max: @get("max_key"),
      values: [@get("min_key"), @get("max_key")]
    
    #
    # handle slider events
    #
    slider.on "slide", (event, ui) =>
      if ui.value == ui.values[0]
        @set "current_lower_key", parseInt(ui.value)
      else if ui.value == ui.values[1]
        @set "current_upper_key", parseInt(ui.value)

    #
    # observe values
    #
    @observe "current_lower_key", (new_value) =>
      $(slider).slider("values", 0, parseInt(new_value))

    @observe "current_upper_key", (new_value) =>
      $(slider).slider("values", 1, parseInt(new_value))

  template: "<div class='cat-histogram-facet-slider {{class}}' style='{{style}}'></div>"
