((window.app ?= {}).components ?= {}).Recommendations = Ractive.extend
  oninit: ->
    # reuse ractive internal component id
    @set("guid", @_guid)

    if @get("url")?
      $.ajax
        url: @get("url")
        type: "GET"
        success: (result) =>
          @set("recommendations", result)

  template: """
    <div data-ractive-guid="{{guid}}">
      {{{recommendations}}}
    </div>
  """
