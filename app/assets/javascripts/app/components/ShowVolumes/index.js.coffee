#= require app/components/Component

app.components.ShowVolumes = app.components.Component.extend
  computed:
    api_v1_scope_searches_path: -> @_path_helper_factory("/api/v1/scopes/:scope_id/searches")
    scope_searches_path: -> @_path_helper_factory("/:scope_id/searches")
    volume_path: -> @_searches_path()

  data:
    i18n_key: "ShowVolumes"

  onconfig: ->
    @set "pending", true

  oninit: ->
    if @get("superorder_id")?
      $.ajax
        url: @_api_searches_path(),
        type: "GET"
        success: (search_result) =>
          @set("show_volumes_link", search_result.hits.length > 0).then =>
            @set "pending", false
    else
      @set "pending", false

  template: """
    {{#if pending}}
      <span class="state loading">
        <i class="fa fa-spinner fa-spin" />
      </span>
    {{else}}
      {{#if show_volumes_link}}
        <a href="{{volume_path}}">{{t(".show_volumes")}}</a>
      {{else}}
        –
      {{/if}}
    {{/if}}
  """

  _api_searches_path: (options = {}) ->
    options.facets ?= false
    options.search_request ?= @_superorder_search_request()
    @get("api_v1_scope_searches_path")(@get("scope.id"), options)

  _searches_path: (options = {}) ->
    options.search_request ?= @_superorder_search_request()
    @get("scope_searches_path")(@get("scope.id"), options)

  _superorder_search_request: (superorder_id = @get("superorder_id")) ->
    queries: [
      type: "query_string"
      query: superorder_id
      default_field: "superorder"
    ]
