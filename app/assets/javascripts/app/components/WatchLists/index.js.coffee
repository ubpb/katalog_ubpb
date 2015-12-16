#= require app/components/Component

app.components.WatchLists = app.components.Component.extend
  computed:
    user_watch_list_path: ->
      @_path_helper_factory("/user/watch_lists/:id")

    watch_lists_the_record_is_on: ->
      @get("watch_lists")?.filter (_watch_list) =>
        if (record_id = @get("record.id"))?
          !!_watch_list?.watch_list_entries?.find (element) =>
            (element.recordid || element.record_id) == record_id

  onrender: ->
    @observe "watch_lists.*.watch_list_entries", => @update("watch_lists_the_record_is_on")

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
