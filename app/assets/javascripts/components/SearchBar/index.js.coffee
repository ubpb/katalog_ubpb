#= require component_helpers
#= require polyfills/Array_filter
#= require polyfills/Array_indexOf
#= require polyfills/Array_map

((window.app ?= {}).components ?= {}).SearchBar = Ractive.extend
  #
  # ractive
  #
  decorators:
    bootstrap_simple_select: (node) ->
      $(node).bootstrapSimpleSelect()
      return teardown: ->

  onconfig: ->
    # ensure every query has a query property
    for query, index in @get("search_request.queries")
      unless query["query"]
        query["query"] = null
        @set("search_request.queries.#{index}", query)

  onrender: ->
    @on "AddQuery", (event) ->
      @add_query(event.context)

    @on "KeypressInSearchInput", (event) ->
      # submit the form if "enter" is pressed while inside the search input
      if event.original.which == 13
        event.original.preventDefault()
        @submit_search_request()

    @on "RemoveQuery", (event) ->
      @remove_query(event.context)

    @on "SubmitSearchRequest", (event) ->
      event.original.preventDefault()
      @submit_search_request()

  #
  # custom
  #
  add_query: (preceding_query) ->
    new_query_index = @get("search_request.queries").indexOf(preceding_query) + 1
    @get("search_request.queries").splice(new_query_index, 0, @query_factory())

  query_factory: ->
    field: @get("searchable_fields")[0][0]
    query: null

  searches_path: (options = {}) ->
    app.ComponentHelpers.path_helper_factory(@get("searches_path"))(options)

  remove_query: (query) ->
    queries = @get("search_request.queries")
    index_of_query_to_remove = queries.indexOf(query)

    if queries.length > 1
      queries.splice(index_of_query_to_remove, 1)

  submit_search_request: ->
    queries = @get("search_request.queries").filter (element) ->
      element["query"].match(/\S/)?

    if queries.length > 0
      path = @searches_path(queries: queries)
      if Turbolinks? then Turbolinks.visit(path) else window.location.href = path
