#= require app/Component
#= require app/components/ComboInput

do(app = (window.app ?= {})) ->
  ((app.components ?= {}).RecordActions ?= {}).Note = app.Component.extend
    components:
      ComboInput: app.components.ComboInput

    computed:
      api_v1_note_path: -> app.PathHelpers.path_helper_factory("/api/v1/notes/:id")
      api_v1_notes_path: -> app.PathHelpers.path_helper_factory("/api/v1/notes")
      note: -> @get("notes")?.find (element) => element?.record_id == @get("record.id")
      i18n_key: -> @parent.get("i18n_key") + ".Note"

    decorators:
      focus: (node) ->
        $(node).focus()
        return teardown: ->

    oninit: ->
      @on "_create_note", @_event_handler_factory (event, note_value) ->
        @_create_note(value: note_value).always =>
          @set("create_mode", false)
          @parent.fire("_close_dropdown")

      @on "_destroy_note", @_event_handler_factory (event) =>
        if window.confirm(@get("t").bind(@)(".destroy_note_confirmation"))
          @_destroy_note().always =>
            @set("update_mode", false)
            @parent.fire("_close_dropdown")
        else
          @set("update_mode", false)
          @parent.fire("_close_dropdown")

      @on "_enter_create_mode", @_event_handler_factory (event) -> @set("create_mode", true)
      @on "_enter_update_mode", @_event_handler_factory (event) -> @set("update_mode", true)
      @on "_leave_create_mode", @_event_handler_factory (event) -> @set("create_mode", false)
      @on "_leave_update_mode", @_event_handler_factory (event) -> @set("update_mode", false)
      @on "_prevent_default",   @_event_handler_factory (event) ->

      @on "_update_note", @_event_handler_factory (event, new_note_value) ->
        @_update_note(value: new_note_value).always =>
          @set("update_mode", false)
          @parent.fire("_close_dropdown")

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
                placeholder={{t(".add_note")}}
                value={{note.value}}
              />
            </a>
          {{else}}
            <a decorator="focus" href="#" on-click="_enter_update_mode">
              <i class="fa fa-pencil" />
              <span>{{t(".edit_note")}}</span>
            </a>
          {{/if}}
        {{else}}
          {{#if create_mode}}
            <a href="#" on-click="_prevent_default">
              <ComboInput
                on-cancel="_leave_create_mode"
                on-escape="_leave_create_mode"
                on-submit="_create_note"
                placeholder={{t(".add_note")}}
              />
            </a>
          {{else}}
            <a decorator="focus" href="#" on-click="_enter_create_mode">
              <i class="fa fa-pencil" />
              <span>{{t(".add_note")}}</span>
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
          url: @get("api_v1_notes_path")()
          type: "POST"
          dataType: "json"
          data:
            record_id: @get("record.id")
            scope_id: @get("scope.id")
            user_id: @get("user.id")
            value: properties.value
          success: (note) =>
            (notes = @get("notes")).push(note)
            @set("notes", notes)

    _destroy_note: ->
      $.ajax
        url: @get("api_v1_note_path")(@get("note.id"))
        type: "DELETE"
        dataType : "html" # because head only responses (automatic) "json" does not work
        success: =>
          notes = @get("notes")
          index_of_note_to_delete = notes.findIndex (element) => element.id == @get("note.id")
          notes.splice(index_of_note_to_delete, 1) if index_of_note_to_delete != -1
          @set("notes", notes)

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
          url: @get("api_v1_note_path")(@get("note.id"))
          type: "PATCH"
          dataType: "json"
          data: properties
          success: (note) =>
            notes = @get("notes")
            index_of_note_to_replace = notes.findIndex (element) => element.id == @get("note.id")
            notes.splice(index_of_note_to_replace, 1, note) if index_of_note_to_replace != -1
            @set("notes", notes)
