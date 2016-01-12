#= require app/Component

do(app = (window.app ?= {})) ->
  (app.components ?= {}).WatchLists = app.Component.extend
    computed:
      user_watch_list_path: ->
        @_path_helper_factory("/user/watch-lists/:id")

      watch_lists_the_record_is_on: ->
        @get("watch_lists")?.filter (_watch_list) =>
          if (record_id = @get("record.id"))?
            !!_watch_list?.watch_list_entries?.find (element) =>
              element.record_id == record_id

    # HACK: adding data-no-turbolink to the link circumvents an issue where watch_lists#show
    # and searches#show may diverge with respect to watch_lists if using browser back/forward
    template: """
      <div style="{{#if watch_lists_the_record_is_on}}{{style}}{{/if}}">
        {{#watch_lists_the_record_is_on}}
          <a href="{{user_watch_list_path(id)}}" style="margin-right: 4px;" data-no-turbolink>
            <span class="label label-info">{{name}}</span>
          </a>
        {{/watch_lists_the_record_is_on}}
      </div>
    """

    _sort_watch_lists: ->
      @get("watch_lists")?.sort (_watch_list, _other_watch_list) ->
        _watch_list.name.localeCompare(_other_watch_list.name)
