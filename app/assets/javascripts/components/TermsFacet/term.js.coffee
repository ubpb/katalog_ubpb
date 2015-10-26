#= require polyfills/Array_find

(((window.app ?= {}).components ?= {}).TermsFacet ?= {}).Term = Ractive.extend
  #
  # ractive
  #
  computed:
    include_term_path: ->
      new_search_request = _.cloneDeep(@parent.get("search_request"))
      @add_facet_query(new_search_request, @parent.get("facet"), @get("term"))
      @reset_from(new_search_request)
      @searches_path(search_request: new_search_request)

    remove_term_path: ->
      new_search_request = _.cloneDeep(@parent.get("search_request"))
      @remove_facet_query(new_search_request, @parent.get("facet"), @get("term"))
      @reset_from(new_search_request)
      @searches_path(search_request: new_search_request)

    selected_by_search_request: ->
      facet_queries = @parent.get("search_request.facet_queries") || []
      !!(facet_queries.find (element) =>
        element["field"] == @parent.get("facet.field") && element["query"] == @get("term")
      )

    translated_term: ->
      i18n_key = @parent.get("facet.i18n_key")
      term     = @get("term")

      if i18n_key
        I18n.t("#{i18n_key}.#{term}", {defaultValue: term})
      else
        term

  template: "{{>content}}"

  #
  # custom
  #
  add_facet_query: (search_request, facet, value, options = {}) ->
    facet_query = {
      field: facet["field"],
      query: value,
      type: "match"
    }

    if options["exclude"] == true
      facet_query["exclude"] = true

    (search_request.facet_queries ?= []).push(facet_query)

  remove_facet_query: (search_request, facet, value, options = {}) ->
    new_facet_queries = _.reject(search_request.facet_queries, (element) =>
      element["field"] == @parent.get("facet.field") && element["query"] == @get("term")
    )

    search_request.facet_queries = if new_facet_queries.length == 0 then undefined else new_facet_queries

  reset_from: (search_request) ->
    search_request.from = undefined # remove from to let server default it

  searches_path: (options = {}) ->
    @parent.searches_path(options)
