#= require app/path_helpers
#= require polyfills/Array_some
#= require polyfills/Object_keys
#= require polyfills/Array_map

do(app = (window.app ?= {})) ->
  (app.components ?= {}).Relations = Ractive.extend
    template: """
      {{#if pending}}
        <span class="state loading">
          <i class="fa fa-spinner fa-spin" />
        </span>
      {{else}}
        {{#if relations.length > 0}}
          <ul>
            {{#relations}}
              <li>{{{label}}}</li>
            {{/relations}}
          </ul>
        {{else}}
          –
        {{/if}}
      {{/if}}
    """

    onconfig: ->
      @set "pending", true

    oninit: ->
      relations  = @get("relations") || []
      target_ids = []

      for relation in relations
        target_ids.push(relation.target_id)

      @link_labels(relations)

      url = @api_searches_path(search_request: {queries: [{
        type: "unscored_terms",
        field: "ht_number",
        terms: target_ids
      }]})

      $.ajax
        url: url,
        type: "GET"
        success: (hits) =>
          @set "relations", relations.filter (relation) ->
            hits.find (element, index, array) ->
              element.record.hbz_id == relation.target_id

          @set "pending", false


    api_searches_path: (options = {}) ->
      app.PathHelpers.path_helper_factory(@get("api_searches_url"))(options)

    searches_path: (options = {}) ->
      app.PathHelpers.path_helper_factory(@get("searches_url"))(options)

    link_labels: (relations) ->
      relations.map (element) =>
        url = @searches_path(search_request:{queries: [{
          type: "query_string",
          query: element.target_id,
          default_field: "ht_number"
        }]})

        element.label = "<a href=\"#{url}\">#{element.label}</a>" if element.target_id
        element
