#= require imagesloaded.pkgd

((window.app ?= {}).components ?= {}).Image = Ractive.extend
  onconfig: ->
    @set "image_dimensions", height: "auto", width: "auto"

  oninit: ->
    $(window).on "resize.#{@_guid}", => @_update_image_dimensions()

  onrender: ->
    imagesLoaded(@el).on "done", (args...) =>
      if $(@el).find("img")[0]?.naturalHeight > 1 && $(@el).find("img")[0]?.naturalWidth > 1
        @_update_image_dimensions()
        @set "image_loaded_successfully", true

  onteardown: ->
    $(window).off ".#{@_guid}"

  template: """
    <div style="height: 100%; width: 100%">
      {{#if src}}
        <img
          src={{src}}
          style="
            {{#unless image_loaded_successfully}}
              display: none;
            {{/unless}}
            height: {{image_dimensions.height}};
            width: {{image_dimensions.width}};
            {{#if style}}
              {{style}}
            {{/if}}
          "
        >
      {{/if}}
      {{#unless image_loaded_successfully}}
        {{{placeholder}}}
      {{/unless}}
    </div>
  """

  _update_image_dimensions: ->
    if image_el = $(@el).find("img")[0]
      image_natural_height = image_el.naturalHeight
      image_natural_width =  image_el.naturalWidth
      height_scaling_factor = $(@el).height() / image_natural_height
      width_scaling_factor = $(@el).width() / image_natural_width
      min_scaling_factor = Math.min(height_scaling_factor, width_scaling_factor)
      @set "image_dimensions.height", "#{image_natural_height * min_scaling_factor}px"
      @set "image_dimensions.width", "#{image_natural_width * min_scaling_factor}px"
