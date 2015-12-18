#= require app/components/Component

app.components.Relations = app.components.Component.extend
  computed:
    api_v1_scope_searches_path: -> @_path_helper_factory("/api/v1/scopes/:scope_id/searches")
    scope_searches_path: -> @_path_helper_factory("/:scope_id/searches")
    target_ids: ->
      if @get("relations")?.length > 0
        target_ids = _.compact(@get("relations").map (element) -> element["target_id"])
        if target_ids.length > 0 then target_ids else undefined

  data:
    relation_path: (relation) ->
      @_searches_path(search_request: @_relation_search_request(relation.target_id))

  onconfig: ->
    @set "pending", true

  oninit: ->
    if @get("target_ids")?
      $.ajax
        url: @_api_searches_path(facets: false, search_request: @_relations_search_request())
        type: "GET"
        success: (search_result) =>
          filtered_relations = @get("relations").filter (relation) ->
            relation.target_id? &&
            search_result.hits.find (element, index, array) ->
              element.record.hbz_id == relation.target_id

          @set("filtered_relations", (if filtered_relations.length > 0 then filtered_relations else null)).then =>
            @set "pending", false

    else
      @set "pending", false

  template: """
    {{#if pending}}
      <span class="state loading">
        <i class="fa fa-spinner fa-spin" />
      </span>
    {{else}}
      {{#if filtered_relations}}
        <ul>
          {{#filtered_relations}}
            <li><a href="{{relation_path(.)}}">{{label}}</a></li>
          {{/filtered_relations}}
        </ul>
      {{else}}
        –
      {{/if}}
    {{/if}}
  """

  _api_searches_path: (options = {}) ->
    @get("api_v1_scope_searches_path")(@get("scope.id"), options)

  _relation_search_request: (hbz_id) ->
    queries: [
      type: "query_string"
      query: hbz_id
      fields: ["ht_number"]
    ]

  _relations_search_request: ->
    from: 0
    size: @get("target_ids").length
    queries: [
      type: "unscored_terms"
      field: "ht_number"
      terms: @get("target_ids")
    ]

  _searches_path: (options = {}) ->
    @get("scope_searches_path")(@get("scope.id"), options)
