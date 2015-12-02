#= require polyfills/Array_some
#= require polyfills/Object_keys

do(app = (window.app ?= {})) ->
  (app.components ?= {}).AvailabilityIndicator = Ractive.extend
    onconfig: ->
      @set "pending", true

    oninit: ->
      $.ajax
        url: @get("url")
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
          <span class="state available">
            <i class="fa fa-check-circle" />
          </span>
        {{elseif not_available}}
          <span class="state not-available">
            <i class="fa fa-minus-circle" />
          </span>
        {{elseif restricted_available}}
          <span class="state restricted-available">
            <i class="fa fa-adjust" />
          </span>
        {{elseif pending}}
          <span class="state loading">
            <i class="fa fa-spinner fa-spin" />
          </span>
        {{/if}}
      </span>
    """

