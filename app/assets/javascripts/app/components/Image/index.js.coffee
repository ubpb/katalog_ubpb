#= require imagesloaded/imagesloaded.pkgd

((window.app ?= {}).components ?= {}).Image = Ractive.extend
  oninit: ->
    # reuse ractive internal component id
    @set("guid", @_guid)

    # set initial state
    if @get("src")
      @set("state", "pending")
    else
      @set("state", "show_placeholder")

  oncomplete: ->
    if @get("state") == "pending"
      component_root = $(@el).find("[data-ractive-guid='#{@get("guid")}']")

      imagesLoaded(component_root).on "done", (args...) =>
        if $(component_root).find("img")[0]?.naturalHeight > 1 && $(component_root).find("img")[0]?.naturalWidth > 1
          @set "state", "show_image"
        else
          @set "state", "show_placeholder"

  template: """
    <div data-ractive-guid="{{guid}}">
      {{#if state == "pending" || state == "show_image" }}
        <img src="{{src}}" style="{{style}}">
        {{#if show_link == "true"}}
          <div style="font-size: 80%; text-align: center">
            <a href="http://www.buchhandel.de" target="_blank">www.buch&shy;handel.de</a>
          </div>
        {{/if}}
      {{/if}}

      {{#if state == "show_placeholder"}}
        {{{placeholder}}}
      {{/if}}
    </div>
  """
