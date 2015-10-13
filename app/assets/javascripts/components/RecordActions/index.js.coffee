#= require component_helpers
#= require ./Note
#= require ./WatchLists

do(
  app = (window.app ?= {}),
  Note = app.components.RecordActions.Note,
  WatchLists = app.components.RecordActions.WatchLists
) ->
  ((app ?= {}).components ?= {}).RecordActions = Ractive.extend
    components:
      Note: Note
      WatchLists: WatchLists

    onconfig: ->
      @["_api_v1_record_path"] = app.ComponentHelpers.path_helper_factory(@get("api_v1_record_path"))

    computed:
      bibtex_path: -> @_api_v1_record_path(@get("record.id"), download: true, format: "bibtex", scope: @get("scope.id"))
      json_path: -> @_api_v1_record_path(@get("record.id"), download: true, format: "json", scope: @get("scope.id"), pretty: true)

    template: """
      <div class="dropdown {{class ? class : ''}}">
        <button class="btn btn-default dropdown-toggle" data-toggle="dropdown">
          <span class="caret"></span>
        </button>

        <ul class="dropdown-menu dropdown-menu-right">
          {{#if user}}
            <WatchLists
              api_v1_user_watch_list_entries_path={{api_v1_user_watch_list_entries_path}}
              api_v1_user_watch_list_entry_path={{api_v1_user_watch_list_entry_path}}
              api_v1_user_watch_lists_path={{api_v1_user_watch_lists_path}}
              record={{record}}
              scope={{scope}}
              translations={{translations}}
              user={{user}}
              watch_lists={{watch_lists}}
            />
            <li class="divider"></li>
            <Note
              api_v1_user_note_path={{api_v1_user_note_path}}
              api_v1_user_notes_path={{api_v1_user_notes_path}}
              note={{note}}
              record={{record}}
              scope={{scope}}
              translations={{translations}}
              user={{user}}
            />
            <li class="divider"></li>
          {{/if}}
          <li class="dropdown-header">{{translations.export}}</li>
          <!-- data-no-turbolink is needed to prevent turbolinks progress bar from staling -->
          <li>
            <a data-no-turbolink href="{{bibtex_path}}">
              <i class="fa fa-download" />
              <span>{{translations.export_to_bibtex}}</span>
            </a>
          </li>
          <li>
            <a data-no-turbolink href="{{json_path}}">
              <i class="fa fa-download" />
              <span>{{translations.export_to_json}}</span>
            </a>
          </li>
        </ul>
      </div>
    """
