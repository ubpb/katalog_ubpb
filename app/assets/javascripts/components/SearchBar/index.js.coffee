#= require component_helpers
#= require jspath
#= require polyfills/Array_filter
#= require polyfills/Array_indexOf
#= require polyfills/Array_map
#= require URIjs/src/URI

((window.app ?= {}).components ?= {}).SearchBar = Ractive.extend
  #
  # ractive
  #
  decorators:
    bootstrap_simple_select: (node) ->
      $(node).bootstrapSimpleSelect()
      return teardown: ->

  oncomplete: ->
    @fire("ready")

  onconfig: ->
    unless @get("search_request.query")
      @set "search_request.query",
        bool:
          must: [@query_string_query_factory()]

    @set "query_string_queries", JSPath("..query_string", @get("search_request")).map (element) ->
      query_string: element

  onrender: ->
    @on "AddQueryStringQuery", (event) ->
      @add_query_string_query(event.context)

    @on "KeypressInSearchInput", (event) ->
      # submit the form if "enter" is pressed while inside the search input
      if event.original.which == 13
        event.original.preventDefault()
        @submit_search_request()

    @on "RemoveQueryStringQuery", (event) ->
      @remove_query_string_query(event.context)

    @on "SubmitSearchRequest", (event) ->
      event.original.preventDefault()
      @submit_search_request()

  #
  # custom
  #
  add_query_string_query: (preceding_query_string_query) ->
    new_query_index = @get("query_string_queries").indexOf(preceding_query_string_query) + 1
    @get("query_string_queries").splice(new_query_index, 0, @query_string_query_factory())

  query_string_query_factory: ->
    query_string:
      default_operator: "AND"
      fields: [@get("search_fields")[0]]
      query: null

  searches_path: (options = {}) ->
    app.ComponentHelpers.path_helper_factory(@get("searches_path"))(options)

  remove_query_string_query: (query_string_query) ->
    query_string_queries = @get("query_string_queries")
    index_of_query_to_remove = query_string_queries.indexOf(query_string_query)

    if query_string_queries.length > 1
      query_string_queries.splice(index_of_query_to_remove, 1)

  submit_search_request: ->
    query_string_queries = @get("query_string_queries").filter (element) ->
      element["query_string"]["query"].match(/\S/)?

    if query_string_queries.length > 0
      newly_created_search_request = _.chain(@get("search_request"))
        .cloneDeep()

        .tap (cloned_search_request) =>
          cloned_search_request["from"] = 0
          cloned_search_request["query"] =
            bool:
              must: query_string_queries

          cloned_search_request["sort"] = [@get("sort_fields")[0]]

        .value()

      path = @searches_path(search_request: newly_created_search_request)
      if Turbolinks? then Turbolinks.visit(path) else window.location.href = path
