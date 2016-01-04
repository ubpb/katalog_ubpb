#= require app/Component
#= require ./Note
#= require ./WatchLists

do(app = window.app, Note = app.components.RecordActions.Note, WatchLists = app.components.RecordActions.WatchLists) ->
  app.components.RecordActions = app.Component.extend
    components:
      Note: Note
      WatchLists: WatchLists

    computed:
      api_v1_scope_record_path: -> @_path_helper_factory("/api/v1/scopes/:scope_id/records/:id")
      bibtex_path: -> @get("api_v1_scope_record_path")(@get("scope.id"), @get("record.id"), download: true, format: "bibtex")
      i18n_key: -> "RecordActions"
      json_path: -> @get("api_v1_scope_record_path")(@get("scope.id"), @get("record.id"), download: true, format: "json")

    template: """
      <div class="dropdown {{class ? class : ''}}">
        <button class="btn btn-default dropdown-toggle" data-toggle="dropdown">
          <span class="caret"></span>
        </button>

        <ul class="dropdown-menu dropdown-menu-right">
          {{#if user}}
            <WatchLists record={{record}} scope={{scope}} user={{user}} watch_lists={{watch_lists}} />
            <!--
            <li class="divider"></li>
            <Note note={{note}} record={{record}} scope={{scope}} user={{user}} />
            -->
            <li class="divider"></li>
          {{/if}}
          <li class="dropdown-header">{{translations.export}}</li>
          <!-- data-no-turbolink is needed to prevent turbolinks progress bar from staling -->
          <li>
            <a data-no-turbolink href="{{bibtex_path}}">
              <i class="fa fa-download" />
              <span>&nbsp;{{t(".export_to_bibtex")}}</span>
            </a>
          </li>
          <li>
            <a data-no-turbolink href="{{json_path}}">
              <i class="fa fa-download" />
              <span>&nbsp;{{t(".export_to_json")}}</span>
            </a>
          </li>
        </ul>
      </div>
    """
