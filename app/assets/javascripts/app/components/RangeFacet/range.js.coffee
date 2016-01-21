#= require app/Component
#= require polyfills/Array_find

do(app = (window.app ?= {})) ->
  ((app.components ?= {}).RangeFacet ?= {}).Range = app.Component.extend
    computed:
      facet_i18n_key: -> "#{@parent.get('i18n_key')}.facets.#{@parent.get('facet.name')}"

      include_range_path: ->
        new_search_request = _.cloneDeep(@parent.get("search_request"))
        @remove_facet_query(new_search_request, @parent.get("facet")) # only one at a time
        @add_facet_query(new_search_request, @parent.get("facet"), @get("from"), @get("to"))
        @reset_from(new_search_request)
        @searches_path(search_request: new_search_request)

      remove_range_path: ->
        new_search_request = _.cloneDeep(@parent.get("search_request"))
        @remove_facet_query(new_search_request, @parent.get("facet"))
        @reset_from(new_search_request)
        @searches_path(search_request: new_search_request)

      included_by_search_request: ->
        facet_queries = @parent.get("search_request.facet_queries") || []
        facet_query = facet_queries.find (_facet_query) =>
          _facet_query["field"] == @parent.get("facet.field")

        if facet_query
          ranges = @parent.get("facet.ranges")
          
          gte_distances = ranges
          .map (_range) =>
            new Date(_range.from) - new Date(facet_query.gte)
          .map (_distance) =>
            if _distance >= 0 then _distance else Number.MAX_SAFE_INTEGER

          minimum_distance = Math.min.apply(Math, gte_distances)
          index = gte_distances.findIndex (_distance) => _distance == minimum_distance
          range = ranges[index]

          range.key == @get("key")

    template: """
      {{#if included_by_search_request}}
        <li class="included">
          <a href="{{remove_range_path}}">
            <div class="label label-info">
              {{t(facet_i18n_key + ".values." + key)}}
              ({{#if count}}{{count}}{{else}}0{{/if}}
            </div>
          </a>
        </li>
      {{else}}
        <li class="default">
          <a href="{{include_range_path}}">
            {{t(facet_i18n_key + ".values." + key)}}
            ({{#if count}}{{count}}{{else}}0{{/if}})
          </a>
        </li>
      {{/if}}
    """

    #
    # custom
    #
    add_facet_query: (search_request, facet, from, to) ->
      facet_query = _.omit({
        field: facet["field"],
        type: "range",
        gte: from,
        lte: to
      }, _.isEmpty)

      (search_request.facet_queries ?= []).push(facet_query)

    remove_facet_query: (search_request, facet) ->
      new_facet_queries = _.reject(search_request.facet_queries, (element) =>
        element["type"] == "range" && element["field"] == @parent.get("facet.field")
      )

      search_request.facet_queries = if new_facet_queries.length == 0 then undefined else new_facet_queries

    reset_from: (search_request) ->
      search_request.from = undefined # remove from to let server default it

    searches_path: (options = {}) ->
      @parent.get("searches_path")(options)
