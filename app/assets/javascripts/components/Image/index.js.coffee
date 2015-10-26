#= require imagesloaded.pkgd

((window.app ?= {}).components ?= {}).Image = Ractive.extend
  onrender: ->
    imagesLoaded(@el).on "done", (args...) =>
      if $(@el).find("img")[0]?.naturalHeight > 1 && $(@el).find("img")[0]?.naturalWidth > 1
        @set "image_loaded_successfully", true

  template: """
    <div>
      {{#if src}}
        <img src={{src}} style="{{#if image_loaded_successfully}}{{style}}{{else}}display: none;{{/if}}">
      {{/if}}

      {{#unless image_loaded_successfully}}
        {{{placeholder}}}
      {{/unless}}
    </div>
  """
