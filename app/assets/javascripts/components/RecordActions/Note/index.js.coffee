#= require component_helpers
#= require components/ComboInput

do(app = (window.app ?= {}), ComboInput = app.components.ComboInput) ->
  ((app.components ?= {}).RecordActions ?= {}).Note = Ractive.extend
    components:
      ComboInput: ComboInput

    decorators:
      focus: (node) ->
        $(node).focus()
        return teardown: ->

    isolated: true

    onconfig: ->
      @["_api_v1_user_note_path"] = app.ComponentHelpers.path_helper_factory(@get("api_v1_user_note_path"))
      @["_api_v1_user_notes_path"] = app.ComponentHelpers.path_helper_factory(@get("api_v1_user_notes_path"))

    oninit: ->
      $(window).on "app:user:note:create.#{@_guid}", (event, note) =>
        @set("note", note) if @get("record.id") == note.record_id && @get("scope.id") == note.scope_id

      $(window).on "app:user:note:destroy.#{@_guid}", (event, note) =>
        @set("note", null) if @get("note.id") == note.id

      $(window).on "app:user:note:update.#{@_guid}", (event, note) =>
        @set("note", note) if @get("note.id") == note.id

      @on "_create_note", @_event_handler_factory (event, note_value) ->
        @_create_note(value: note_value).always => @set("create_mode", false)

      @on "_destroy_note", @_event_handler_factory (event) ->
        if window.confirm(@get("translations.destroy_note_confirmation"))
          @_destroy_note().always => @set("update_mode", false)
        else
          @set("update_mode", false)

      @on "_enter_create_mode", @_event_handler_factory (event) -> @set("create_mode", true)
      @on "_enter_update_mode", @_event_handler_factory (event) -> @set("update_mode", true)
      @on "_leave_create_mode", @_event_handler_factory (event) -> @set("create_mode", false)
      @on "_leave_update_mode", @_event_handler_factory (event) -> @set("update_mode", false)
      @on "_prevent_default",   @_event_handler_factory (event) ->

      @on "_update_note", @_event_handler_factory (event, new_note_value) ->
        @_update_note(value: new_note_value).always => @set("update_mode", false)

    onteardown: ->
      $(window).off ".#{@_guid}"

    template: """
      <li>
        {{#if note}}
          {{#if update_mode}}
            <a href="#" on-click="_prevent_default">
              <ComboInput
                on-cancel="_destroy_note"
                on-escape="_leave_update_mode"
                on-submit="_update_note"
                placeholder={{translations.add_note}}
                value={{note.value}}
              />
            </a>
          {{else}}
            <a decorator="focus" href="#" on-click="_enter_update_mode">
              <i class="fa fa-pencil" />
              <span>{{translations.edit_note}}</span>
            </a>
          {{/if}}
        {{else}}
          {{#if create_mode}}
            <a href="#" on-click="_prevent_default">
              <ComboInput
                on-cancel="_leave_create_mode"
                on-escape="_leave_create_mode"
                on-submit="_create_note"
                placeholder={{translations.add_note}}
              />
            </a>
          {{else}}
            <a decorator="focus" href="#" on-click="_enter_create_mode">
              <i class="fa fa-pencil" />
              <span>{{translations.add_note}}</span>
            </a>
          {{/if}}
        {{/if}}
      </li>
    """

    _create_note: (properties) ->
      # shortcut if nothing to create
      if !properties.value
        $.Deferred().reject().promise()
      else
        $.ajax
          url: @_api_v1_user_notes_path(@get("user.id"))
          type: "POST"
          dataType: "json"
          data:
            record_id: @get("record.id")
            scope_id: @get("scope.id")
            value: properties.value
          success: (received_note) =>
            $(window).trigger("app:user:note:create", _.cloneDeep(received_note))

    _destroy_note: ->
      $.ajax
        url: @_api_v1_user_note_path(@get("user.id"), @get("note.id"))
        type: "DELETE"
        dataType : "html" # because head only responses (automatic) "json" does not work
        success: =>
          $(window).trigger("app:user:note:destroy", _.cloneDeep(@get("note")))

    _event_handler_factory: (fn = (->), options = {}) ->
      (event, args...) ->
        event?.original?.preventDefault()
        fn.bind(@)(event, args...)
        false # stops dom/ractive event bubling

    _update_note: (properties) ->
      # shortcut if nothing to change
      if Object.keys(properties).length == 1 && properties.value == @get("note.value")
        $.Deferred().reject().promise()
      else
        $.ajax
          url: @_api_v1_user_note_path(@get("user.id"), @get("note.id"))
          type: "PATCH"
          dataType: "json"
          data: properties
          success: (note) =>
            $(window).trigger("app:user:note:update", _.cloneDeep(note))
