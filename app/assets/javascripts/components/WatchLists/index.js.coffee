#= require component_helpers
#= require polyfills/Array_find

((window.App ?= {}).components ?= {}).WatchLists = Ractive.extend
  onconfig: ->
    @set "watch_lists", [] unless @get("watch_lists")
    @set "user_watch_list_path", app.ComponentHelpers.path_helper_factory(@get("user_watch_list_path"))
    @_sort_watch_lists()

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

  onteardown: ->
    $(window).off ".#{@_guid}"

  computed:
    watch_lists_the_record_is_on: ->
      @get("watch_lists").filter (watch_list) =>
        !!watch_list.entries.find((element) => element.record_id == @get("record")?.id)

  template: """
    <div style="{{#if watch_lists_the_record_is_on}}{{style}}{{/if}}">
      {{#watch_lists_the_record_is_on}}
        <a href="{{user_watch_list_path(id)}}" style="margin-right: 4px;">
          <span class="label label-info">{{name}}</span>
        </a>
      {{/watch_lists_the_record_is_on}}
    </div>
  """

  _sort_watch_lists: ->
    @get("watch_lists")?.sort (_watch_list, _other_watch_list) ->
      _watch_list.name.localeCompare(_other_watch_list.name)
