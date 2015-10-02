($ = jQuery).fn.extend
  trunker: (options) ->
    trunker = class
      button_html: (inner_html) ->
        """
          <a
           class='btn btn-default'
           style='position: absolute; font-size: #{parseInt(@el.css("font-size")) - 2}px; padding: 0px 4px 1px 4px; right: 0px; top: 0px;'
          >#{inner_html}</a>
        """

      constructor: (@el) ->
        @el.css("position", "relative")
        @collapse_button = $(@button_html("<i class='fa fa-chevron-up'></i>")).hide().on("click", @collapse)
        @expand_button = $(@button_html("<i class='fa fa-chevron-down'></i>")).hide().on("click", @expand)
        @el.append(@collapse_button).append(@expand_button)
        @collapse()

      collapse: =>
        @el.css("overflow", "hidden")
        @el.height(@el.css("line-height"))
        @expand_button.show()
        @collapse_button.hide()

      expand: =>
        @el.height("auto")
        @collapse_button.show()
        @expand_button.hide()

    return @each () ->
      if (element = $(@)).height() > parseInt(element.css("line-height"))
        new trunker(element)
