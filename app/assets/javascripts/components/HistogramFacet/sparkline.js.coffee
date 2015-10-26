#= require jquery.sparkline

(((window.app ?= {}).components ?= {}).HistogramFacet ?= class).Sparkline = Ractive.extend
  onconstruct: ->
    $(window).on "resize", => @onrender()

  onrender: ->
    sparkline_values = @get("entries").map (entry) ->
      [entry.key.toString(), entry.count]

    $(@el).find(".sparkline").empty().sparkline sparkline_values,
      height: "100%",
      numberFormatter: (number) -> number.toString(),
      tooltipFormat: "<span>{{prefix}}{{x}} ({{y}}){{suffix}}</span>",
      width: "100%"

  template: "<div class='sparkline {{class}}' style='{{style}}'></div>"
