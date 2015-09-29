#= require utils/deep_locate
#= require jsonpath

(((window.app ?= {}).components ?= {}).TermsFacet ?= {}).Term = Ractive.extend
  #
  # ractive
  #
  computed:
    deselect_term_path: ->
      unfacetted_search_request = _.cloneDeep @parent.get("search_request")

      for match_query_parent in JSONPath({json: unfacetted_search_request, path: "$..match^^^"})
        _.remove match_query_parent, (query) =>
          query["match"]?[@facet_name()] == @undecorated_term()["term"]

      @searches_path(search_request: unfacetted_search_request)

    select_term_path: ->
      # construct the match query
      (match_query = { match: {} })["match"][@facet_name()] = @undecorated_term()["term"]

      facetted_search_request = _.chain(@parent.get("search_request"))
        # clone the original search request to prevent modification
        .cloneDeep()

        # add the creeated match query
        .tap (cloned_search_request) ->
          cloned_search_request.query.bool.must.push(match_query)

        # reset pagination on the newly created search request
        .tap (cloned_search_request) ->
          cloned_search_request.from = 0

        # unchain the value
        .value()

      # return the records path for the facetted search request
      @searches_path(search_request: facetted_search_request)

    selected_by_search_request: ->
      # JSONPath does not work if key names contain dots
      relevant_match_queries = app.utils.deep_locate @parent.get("search_request"), (_key, _value, _object) =>
        _is_match = _key == "match"
        _children_with_matching_key_value = app.utils.deep_locate _object, (__key, __value, __object) =>
          __key == @facet_name() && __value == @undecorated_term()["term"]

        _is_match && _children_with_matching_key_value.length > 0

      relevant_match_queries.length > 0

  template: "{{>content}}"

  #
  # custom
  #
  facet_name: ->
    @parent.undecorated_facet()["name"]

  undecorated_term: ->
    _.chain(_.zip(@parent.decorated_facet()["terms"], @parent.undecorated_facet()["terms"]))
      .select (tuple) => tuple[0].term == @get("term")
      .map (tuple) => tuple[1]
      .first()
      .value()

  searches_path: (options = {}) ->
    @parent.searches_path(options)
