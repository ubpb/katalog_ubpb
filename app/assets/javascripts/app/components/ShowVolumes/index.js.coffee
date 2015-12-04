#= require app/path_helpers
#= require polyfills/Array_some
#= require polyfills/Object_keys
#= require polyfills/Array_map

do(app = (window.app ?= {})) ->
  (app.components ?= {}).ShowVolumes = Ractive.extend
    template: """
      {{#if pending}}
        <span class="state loading">
          <i class="fa fa-spinner fa-spin" />
        </span>
      {{else}}
        {{#if show_volumes_link}}
          <a href="{{show_volumes_url}}">
            {{label}}
          </a>
        {{else}}
          –
        {{/if}}
      {{/if}}
    """

    onconfig: ->
      @set "pending", true

    oninit: ->
      search_request = search_request:{queries: [{
        type: "query_string",
        query: @get("superorder_id"),
        default_field: "superorder"
      }]}

      @set "show_volumes_url", @searches_path(search_request)

      $.ajax
        url: @api_searches_path(search_request),
        type: "GET"
        success: (hits) =>
          @set "show_volumes_link", hits.length > 0
          @set "pending", false


    api_searches_path: (options = {}) ->
      app.PathHelpers.path_helper_factory(@get("api_searches_url"))(options)

    searches_path: (options = {}) ->
      app.PathHelpers.path_helper_factory(@get("searches_url"))(options)
