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
      id: -> @_guid
      json_path: -> @get("api_v1_scope_record_path")(@get("scope.id"), @get("record.id"), download: true, format: "json")
      login_path: -> @_path_helper_factory("/login")(return_to: @get("current_path"), redirect: "true")

    oninit: ->
      @on "_close_dropdown", (event) ->
        # some sort of hack, but .dropdown("toggle") does not allow to reopen the dropdown
        $(@el).find("##{@get('id')}").trigger("click")

    template: """
      <div id={{id}} class="dropdown {{class ? class : ''}}">
        <button class="btn btn-default dropdown-toggle" data-toggle="dropdown">
          <span class="caret"></span>
        </button>

        <ul class="dropdown-menu dropdown-menu-right">
          <li class="dropdown-header">{{t(".my_watch_lists")}}</li>
          {{#if user}}
            <WatchLists record={{record}} scope={{scope}} user={{user}} watch_lists={{watch_lists}} />
            <li class="divider"></li>
            <Note notes={{notes}} record={{record}} scope={{scope}} user={{user}} />
            <li class="divider"></li>
          {{else}}
            <li>
              <a style="font-style: italic" href="{{login_path}}">{{t(".please_login")}}</a>
            </li>
          {{/if}}
          <li class="dropdown-header">{{t(".export")}}</li>
          <!-- data-no-turbolink is needed to prevent turbolinks progress bar from staling -->
          <li>
            <a data-no-turbolink href="{{bibtex_path}}">
              <i class="fa fa-download" />
              <span>&nbsp;{{t(".export_to_bibtex")}}</span>
            </a>
          </li>
          <!--
          <li>
            <a data-no-turbolink href="{{json_path}}">
              <i class="fa fa-download" />
              <span>&nbsp;{{t(".export_to_json")}}</span>
            </a>
          </li>
          -->
        </ul>
      </div>
    """
