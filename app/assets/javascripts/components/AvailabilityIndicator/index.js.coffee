#= require component_helpers
#= require utils/CssHelper
#= require polyfills/Array_some
#= require polyfills/Object_keys

do(app = (window.app ?= {})) ->
  (app.components ?= {}).AvailabilityIndicator = Ractive.extend
#    _css: (key) ->
#      debugger
#      app.Utils.CssHelper.normalize """
#        border-radius: 10px;
#        color: white;
#        padding-left: 5px;
#        padding-right: 5px;
#      """ + (
#        switch key
#          when "available" then "background-color: rgba(70, 165, 70, 0.8);"
#          when "not_available" then "background-color: rgba(204, 21, 0, 0.8);"
#          when "restricted_available" then "background-color: rgba(255, 196, 13, 0.8);"
#      ) +
#      if @get("style")? then @get("style") else ""

    onconfig: ->
      @set "pending", true
      @["api_v1_record_items_path"] = app.ComponentHelpers.path_helper_factory(@get("api_v1_record_items_path"))

    oninit: ->
      $.ajax
        url: @api_v1_record_items_path(@get("record_id"), scope: @get("scope_id"))
        type: "GET"
        success: (items) =>
          @set "pending", false

          if (items.some (item) -> item["availability"] == "available")
            @set("available", true)
          else if (items.some (item) -> item["availability"] == "restricted_available")
            @set("restricted_available", true)
          else if (items.some (item) -> item["availability"] == "not_available")
            @set("not_available", true)

    # the container is needed or the indicator is appended to the end of the
    # elements children because it seems it is delete once and reinserted
    # when pending etc. changes
    template: """
      <span class="availability-indicator">
        {{#if available}}
          <span>
            <i class="fa fa-check-circle" />
          </span>
        {{elseif not_available}}
          <span>
            <i class="fa fa-minus-circle" />
          </span>
        {{elseif restricted_available}}
          <span>
            <i class="fa fa-adjust" />
          </span>
        {{elseif pending}}
          <span>
            <i class="fa fa-spinner fa-spin" />
          </span>
        {{/if}}
      </span>
    """

