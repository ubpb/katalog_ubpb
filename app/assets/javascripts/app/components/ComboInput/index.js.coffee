do(app = (window.app ?= {})) ->
  (app.components ?= {}).ComboInput = Ractive.extend
    onconfig: ->
      @_reset_input()

    oninit: ->
      @on "_escape", @_event_handler_factory (event) ->
        @fire "escape", event
        @_reset_input()

      @on "_submit", @_event_handler_factory (event) ->
        @fire "submit", event, @get("_input")

      @on "_cancel", @_event_handler_factory (event) ->
        @fire "cancel", event
        @_reset_input()

    template: """
      <div class="input-group" style="min-width: 210px;">
        <input
          autofocus
          class="form-control input-xs"
          on-enter="_submit"
          on-escape="_escape"
          placeholder={{placeholder}}
          style="height: auto; padding-top: 1px; padding-bottom: 1px;"
          type="text"
          value={{_input}}
        />
        <div class="input-group-btn">
          <button class="btn btn-primary btn-xs" on-click="_submit">
            <i class="fa fa-check" />
          </button>
          <button class="btn btn-default btn-xs" on-click="_cancel">
            <i class="fa fa-times" />
          </button>
        </div>
      </div>
    """

    _event_handler_factory: (fn = (->), options = {}) ->
      (event, args...) ->
        event?.original?.preventDefault()
        fn.bind(@)(event, args...)
        false # stops dom/ractive event bubling

    _reset_input: ->
      @set("_input", @get("value") || "")
