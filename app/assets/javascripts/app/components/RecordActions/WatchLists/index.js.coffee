#= require app/components/ComboInput
#= require app/path_helpers

do(app = (window.app ?= {}), ComboInput = app.components.ComboInput) ->
  ((app.components ?= {}).RecordActions ?= {}).WatchLists = Ractive.extend
    components:
      ComboInput: ComboInput

    data:
      record_on_watch_list: (record, watch_list) ->
        !!watch_list.entries.find((element) => element.record_id == record.id)

    decorators:
      focus: (node) ->
        $(node).focus()
        return teardown: ->

    isolated: true

    onconfig: ->
      @_sort_watch_lists()

      @["_api_v1_user_watch_list_entries_path"] = app.PathHelpers.path_helper_factory(@get("api_v1_user_watch_list_entries_path"))
      @["_api_v1_user_watch_list_entry_path"] = app.PathHelpers.path_helper_factory(@get("api_v1_user_watch_list_entry_path"))
      @["_api_v1_user_watch_lists_path"] = app.PathHelpers.path_helper_factory(@get("api_v1_user_watch_lists_path"))

    oninit: ->
      $(window).on "app:user:watch_list:create.#{@_guid}", (event, watch_list) =>
        @get("watch_lists").push(watch_list)
        @_sort_watch_lists()

      $(window).on "app:user:watch_list:entry:create.#{@_guid}", (event, entry) =>
        for _watch_list in (_watch_lists = @get("watch_lists"))
          if _watch_list.id == entry.watch_list_id
            _watch_list.entries.push(entry)

        @set("watch_lists", _watch_lists)

      $(window).on "app:user:watch_list:entry:destroy.#{@_guid}", (event, entry) =>
        for _watch_list in (_watch_lists = @get("watch_lists"))
          if _watch_list.id == entry.watch_list_id
            _watch_list.entries = _watch_list.entries.filter (_entry) => _entry.id != entry.id

        @set("watch_lists", _watch_lists)

      @on "_add_record_to_watch_list", @_event_handler_factory (event, record, watch_list) ->
        @_create_watch_list_entry(watch_list.id, record: record, scope: @get("scope"))
      , stop_propagation: false

      @on "_create_watch_list", @_event_handler_factory (event, watch_list_name) ->
        @set("create_watch_list_pending", true)
        @_create_watch_list(name: watch_list_name).always =>
          @set("create_mode", false)
          @set("create_watch_list_pending", false)

      @on "_enter_create_mode", @_event_handler_factory (event) -> @set("create_mode", true)
      @on "_leave_create_mode", @_event_handler_factory (event) -> @set("create_mode", false)
      @on "_prevent_default",   @_event_handler_factory (event) ->

      @on "_remove_record_from_watch_list", @_event_handler_factory (event, record, watch_list) ->
        entry = watch_list.entries.find((element) => element.record_id == record.id)
        @_destroy_watch_list_entry(watch_list, entry)
      , stop_propagation: false

    onteardown: ->
      $(window).off ".#{@_guid}"

    template: """
      <li class="dropdown-header">{{translations.my_watch_lists}}</li>
      {{#watch_lists}}
        <li>
          {{#if record_on_watch_list(~/record, .)}}
            <a decorator="focus" href="#" on-click="_remove_record_from_watch_list:{{~/record}},{{.}}">
              <i class="fa fa-times" />
              <span>{{name}}</span>
            </a>
          {{else}}
            <a decorator="focus" href="#" on-click="_add_record_to_watch_list:{{~/record}},{{.}}">{{name}}</a>
          {{/if}}
        </li>
      {{/watch_lists}}
      <li>
        {{#if create_watch_list_pending}}
          <a href="#" on-click="_prevent_default">
            <i class="fa fa-spinner fa-spin" />
          </a>
        {{elseif create_mode}}
          <a href="#" on-click="_prevent_default">
            <ComboInput
              on-cancel="_leave_create_mode"
              on-escape="_leave_create_mode"
              on-submit="_create_watch_list"
              placeholder={{translations.create_watch_list}}
            />
          </a>
        {{else}}
          <a decorator="focus" href="#" on-click="_enter_create_mode">
            <i class="fa fa-plus" />
            <span style="font-style: italic;">{{translations.create_watch_list}}</span>
          </a>
        {{/if}}
      </li>
    """

    _create_watch_list_entry: (watch_list_id, entry) ->
      $.ajax
        url: @_api_v1_user_watch_list_entries_path(@get("user.id"), watch_list_id)
        type: "POST"
        data: entry
        success: (entry) =>
          $(window).trigger "app:user:watch_list:entry:create", _.cloneDeep(entry)

    _create_watch_list: (properties) ->
      if !properties.name # shortcut for nothing to create
        $.Deferred().reject().promise()
      else
        $.ajax
          url: @_api_v1_user_watch_lists_path(@get("user.id"))
          type: "POST"
          data:
            watch_list:
              name: properties.name
          success: (watch_list) =>
            $(window).trigger "app:user:watch_list:create", _.cloneDeep(watch_list)

    _destroy_watch_list_entry: (watch_list, entry) ->
      $.ajax
        url: @_api_v1_user_watch_list_entry_path(@get("user.id"), watch_list.id, entry.id)
        type: "DELETE"
        success: =>
          $(window).trigger "app:user:watch_list:entry:destroy", $.extend({
            watch_list_id: watch_list.id
          }, entry)

    _event_handler_factory: (fn = (->), options = {}) ->
      options.prevent_default ?= true
      options.stop_propagation ?= true

      (event, args...) ->
        event?.original?.preventDefault() if options.prevent_default is true
        fn.bind(@)(event, args...)

        # stops dom/ractive event bubling if requested
        if options.stop_propagation is true then false else true

    _sort_watch_lists: ->
      @get("watch_lists")?.sort (_watch_list, _other_watch_list) ->
        _watch_list.name.localeCompare(_other_watch_list.name)
