#= require app/path_helpers
#= require polyfills/Array_filter
#= require polyfills/Array_indexOf
#= require polyfills/Array_map

((window.app ?= {}).components ?= {}).SearchBar = Ractive.extend
  template: """
    <div class="search-bar">
      <div class="visible-sm-block visible-md-block visible-lg-block">
        {{#each search_request.queries}}
          <div class="row">
            <div class="{{#if search_request.queries.length == 1}}col-sm-9{{else}}col-sm-12{{/if}}">
              <div class="input-group">
                <input class="form-control query" autocomplete="off" autofocus="" placeholder="Suchbegriff" value="{{query}}" on-keypress="KeypressInSearchInput" />
                <div class="input-group-btn">
                  {{#if type === "simple_query_string"}}
                    <select class="field" decorator="bootstrap_simple_select" value="{{fields[0]}}">
                      {{#searchable_fields}}
                        <option value="{{this}}">{{t(i18n_key + ".fields." + this, { defaultValue: this })}}</option>
                      {{/searchable_fields}}
                    </select>
                  {{/if}}

                  <button class="btn btn-default" type="button" on-click="AddQuery">
                    <i class="fa fa-plus-circle"></i>
                  </button>

                  <button class="btn btn-default {{search_request.queries.length == 1 ? 'disabled' : ''}}" type="button" on-click="RemoveQuery">
                    <i class="fa fa-minus-circle"></i>
                  </button>
                </div>
              </div>
            </div>

            {{#if search_request.queries.length == 1}}
              <div class="col-sm-3">
                <button class="btn btn-primary form-control search-button" on-click="SubmitSearchRequest">
                  <i class="fa fa-search"></i>
                  {{ t("components.SearchBar.search") }}
                </button>
              </div>
            {{/if}}
          </div>
        {{/each}}

        {{#if search_request.queries.length > 1}}
          <div class="row">
            <div class="col-sm-3">
              <button class="btn btn-primary form-control search-button" on-click="SubmitSearchRequest">
                <i class="fa fa-search"></i>
                {{ t("components.SearchBar.search") }}
              </button>
            </div>
          </div>
        {{/if}}
      </div>
      <div class="visible-xs">
        {{#each search_request.queries}}
          <div class="row">
            <div class="col-xs-12 searchable-fields">
              {{#if type === "simple_query_string"}}
                <select class="field" decorator="bootstrap_simple_select" value="{{fields[0]}}">
                  {{#searchable_fields}}
                    <option value="{{this}}">{{t(i18n_key + ".fields." + this, { defaultValue: this })}}</option>
                  {{/searchable_fields}}
                </select>
              {{/if}}
            </div>
            <div class="col-xs-12 query">
              <input class="form-control" autocomplete="off" autofocus="" placeholder="Suchbegriff" value="{{query}}" on-keypress="KeypressInSearchInput" />
            </div>
            <div class="col-xs-12 add-remove-query">
              <div class="btn-group">
                <button class="btn btn-default" type="button" on-click="AddQuery">
                  <i class="fa fa-plus-circle"></i>
                </button>
                <button class="btn btn-default {{search_request.queries.length == 1 ? 'disabled' : ''}}" type="button" on-click="RemoveQuery">
                  <i class="fa fa-minus-circle"></i>
                </button>
              </div>
            </div>
          </div>
        {{/each}}
        <div class="row">
          <div class="col-xs-12">
            <button class="btn btn-primary form-control search-button" on-click="SubmitSearchRequest">
              <i class="fa fa-search"></i>
              {{ t("components.SearchBar.search") }}
            </button>
          </div>
        </div>
      </div>
    </div>
  """
  
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
    @get("search_request.queries").splice(new_query_index, 0, @query_factory(type: "simple_query_string"))

  query_factory: (options = {}) ->
    if options["type"] == "query_string"
      default_field: @get("searchable_fields")[0][0]
      query: null
      type: "query_string"
    else if options["type"] == "simple_query_string"
      field: @get("searchable_fields")[0][0]
      query: null
      type: "simple_query_string"

  searches_path: (options = {}) ->
    app.PathHelpers.path_helper_factory(@get("searches_path"))(options)

  remove_query: (query) ->
    queries = @get("search_request.queries")
    index_of_query_to_remove = queries.indexOf(query)

    if queries.length > 1
      queries.splice(index_of_query_to_remove, 1)

  submit_search_request: ->
    queries = @get("search_request.queries").filter (element) ->
      element["query"].match(/\S/)?

    if queries.length > 0
      path = @searches_path(search_request: { queries: queries, sort: @get("default_sort") })
      if Turbolinks? then Turbolinks.visit(path) else window.location.href = path
