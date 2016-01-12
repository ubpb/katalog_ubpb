#= require app/Component
#= require app/components/ComboInput
#= require app/path_helpers

do(app = (window.app ?= {})) ->
  ((app.components ?= {}).RecordActions ?= {}).WatchLists = app.Component.extend
    components:
      ComboInput: app.components.ComboInput

    computed:
      api_v1_user_watch_lists_path: -> app.PathHelpers.path_helper_factory("/api/v1/users/:user_id/watch_lists")
      api_v1_watch_list_entry_path: -> app.PathHelpers.path_helper_factory("/api/v1/watch_list_entries/:id")
      api_v1_watch_list_watch_list_entries_path: -> app.PathHelpers.path_helper_factory("/api/v1/watch_lists/:watch_list_id/watch_list_entries")
      i18n_key: -> @parent.get("i18n_key") + ".WatchLists"

    data:
      record_on_watch_list: (record, watch_list) ->
        !!@_watch_list_entry_by_record_id(watch_list, record.id)

    decorators:
      focus: (node) ->
        $(node).focus()
        return teardown: ->

    oninit: ->
      @on "AddRecordToWatchList", @_event_handler_factory (event, record, watch_list) ->
        @_create_watch_list_entry(watch_list.id, record.id, @get("scope.id"))
      , stop_propagation: false

      @on "CreateWatchList", @_event_handler_factory (event, watch_list_name) ->
        @set("create_watch_list_pending", true)
        @_create_watch_list(watch_list_name).always =>
          @set("create_mode", false)
          @set("create_watch_list_pending", false)

      @on "EnterCreateMode", @_event_handler_factory (event) -> @set("create_mode", true)
      @on "LeaveCreateMode", @_event_handler_factory (event) -> @set("create_mode", false)
      @on "PreventDefault",   @_event_handler_factory (event) ->

      @on "RemoveRecordFromWatchList", @_event_handler_factory (event, record, watch_list) ->
        if watch_list_entry = @_watch_list_entry_by_record_id(watch_list, record.id)
          @_delete_watch_list_entry(watch_list_entry.id)
      , stop_propagation: false

    onteardown: ->
      $(window).off ".#{@_guid}"

    template: """
      {{#watch_lists}}
        <li>
          {{#if record_on_watch_list(~/record, .)}}
            <a decorator="focus" href="#" on-click="RemoveRecordFromWatchList:{{~/record}},{{.}}">
              <i class="fa fa-check-square-o" />
              <span>{{name}}</span>
            </a>
          {{else}}
            <a decorator="focus" href="#" on-click="AddRecordToWatchList:{{~/record}},{{.}}">
              <i class="fa fa-square-o" />
              {{name}}
            </a>
          {{/if}}
        </li>
      {{/watch_lists}}
      <li>
        {{#if create_watch_list_pending}}
          <a href="#" on-click="PreventDefault">
            <i class="fa fa-spinner fa-spin" />
          </a>
        {{elseif create_mode}}
          <a href="#" on-click="PreventDefault">
            <ComboInput
              on-cancel="LeaveCreateMode"
              on-escape="LeaveCreateMode"
              on-submit="CreateWatchList"
              placeholder={{t(".create_watch_list")}}
            />
          </a>
        {{else}}
          <a decorator="focus" href="#" on-click="EnterCreateMode">
            <i class="fa fa-plus" />
            <span style="font-style: italic;">{{t(".create_watch_list")}}</span>
          </a>
        {{/if}}
      </li>
    """

    _create_watch_list_entry: (watch_list_id, record_id, scope_id) ->
      $.ajax
        url: @get("api_v1_watch_list_watch_list_entries_path")(watch_list_id)
        type: "POST"
        data:
          record_id: record_id
          scope_id: scope_id
        success: (watch_list_entry) =>
          watch_list_index = @get("watch_lists").findIndex (element) => element.id == watch_list_id
          watch_list_entries_keypath = "watch_lists.#{watch_list_index}.watch_list_entries"
          @set(watch_list_entries_keypath, @get(watch_list_entries_keypath).concat(watch_list_entry))

    _create_watch_list: (name) ->
      if !name # shortcut for nothing to create
        $.Deferred().reject().promise()
      else
        $.ajax
          url: @get("api_v1_user_watch_lists_path")(@get("user.id"))
          type: "POST"
          data:
            name: name
          success: (watch_list) =>
            watch_list["watch_list_entries"] ?= []
            new_watch_lists = @get("watch_lists").concat(watch_list)
            @set("watch_lists", new_watch_lists)

    _delete_watch_list_entry: (id) ->
      $.ajax
        dataType: "text" # else success will not be called because an empty "head :ok" response is not valid JSON
        url: @get("api_v1_watch_list_entry_path")(id)
        type: "DELETE"
        success: =>
          watch_list_index = @get("watch_lists").findIndex (_watch_list) =>
            _watch_list?.watch_list_entries?.find (_watch_list_entry) =>
              _watch_list_entry.id == id

          watch_list_entry_index = @get("watch_lists.#{watch_list_index}")?.watch_list_entries?.findIndex (_watch_list_entry) =>
            _watch_list_entry.id == id

          if watch_list_index >= 0 && watch_list_entry_index >= 0
            watch_list_entries_keypath = "watch_lists.#{watch_list_index}.watch_list_entries"
            (new_watch_list_entries = @get(watch_list_entries_keypath)).splice(watch_list_entry_index, 1)
            @set(watch_list_entries_keypath, new_watch_list_entries)
            #@get("watch_lists.#{watch_list_index}.watch_list_entries").splice(watch_list_entry_index, 1)

    _event_handler_factory: (fn = (->), options = {}) ->
      options.prevent_default ?= true
      options.stop_propagation ?= true

      (event, args...) ->
        event?.original?.preventDefault() if options.prevent_default is true
        fn.bind(@)(event, args...)

        # stops dom/ractive event bubling if requested
        if options.stop_propagation is true then false else true

    _watch_list_entry_by_record_id: (watch_list, record_id) ->
      watch_list?.watch_list_entries?.find (element) => element.record_id == record_id
