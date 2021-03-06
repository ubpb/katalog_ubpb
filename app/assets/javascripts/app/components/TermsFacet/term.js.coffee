#= require polyfills/Array_find

(((window.app ?= {}).components ?= {}).TermsFacet ?= {}).Term = Ractive.extend
  template: """
    {{#if included_by_search_request}}
      <li class="included">
        <a href="{{remove_term_path}}">
          <div class="label label-info">
            {{translated_term}}
            {{#if count}}({{count}}){{/if}}
          </div>
        </a>
      </li>
    {{elseif excluded_by_search_request}}
      <li class="excluded">
        <a href="{{remove_term_path}}">
          {{translated_term}}
        </a>
      </li>
    {{else}}
      <li class="default">
        <a href="{{include_term_path}}">
          {{translated_term}}
          <span style="white-space: nowrap;">
            {{#if count}}({{count}}){{/if}}
            {{#if can_exclude}}<span on-click="ExcludeTerm"><i class="fa fa-remove"></i></span>{{/if}}
          </span>
        </a>
      </li>
    {{/if}}
  """

  computed:
    can_exclude: ->
      facet = @parent.get("facet")
      return facet.name != "tlevel"

    exclude_term_path: ->
      new_search_request = _.cloneDeep(@parent.get("search_request"))
      @add_facet_query(new_search_request, @parent.get("facet"), @get("term"), exclude: true)
      @reset_from(new_search_request)
      @searches_path(search_request: new_search_request)

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

    included_by_search_request: ->
      facet_queries = @parent.get("search_request.facet_queries") || []
      !!(facet_queries.find (element) =>
        element["field"] == @parent.get("facet.field") && element["query"] == @get("term") && !element["exclude"]
      )

    excluded_by_search_request: ->
      facet_queries = @parent.get("search_request.facet_queries") || []
      !!(facet_queries.find (element) =>
        element["field"] == @parent.get("facet.field") && element["query"] == @get("term") && element["exclude"]
      )

    translated_term: ->
      i18n_key = @parent.get("i18n_key")
      facet_name = @parent.get("facet.name")
      term = @decode_term(@get("term"))

      if i18n_key
        I18n.t("#{i18n_key}.facets.#{facet_name}.values.#{term}", {defaultValue: term})
      else
        term

  oninit: ->
    @on "ExcludeTerm", (event) ->
      event.original.preventDefault()
      @exclude_term()

  #
  # custom
  #
  add_facet_query: (search_request, facet, value, options = {}) ->
    facet_query = _.omit({
      field: facet["field"],
      query: value,
      type: "match",
      exclude: options["exclude"]
    }, _.isEmpty)

    if options["exclude"] == true
      facet_query["exclude"] = true

    (search_request.facet_queries ?= []).push(facet_query)

  # http://stackoverflow.com/questions/1912501/unescape-html-entities-in-javascript
  decode_html_entities: (string) ->
    new DOMParser().parseFromString(string, "text/html").documentElement.textContent

  decode_term: (term) ->
    phase_one = @decode_html_entities(term)
    phase_two = phase_one
      .replace "&Apos;", "&apos;"

    @decode_html_entities(phase_two)

  exclude_term: ->
    path = @computed.exclude_term_path.call(@)
    if Turbolinks? then Turbolinks.visit(path) else window.location.href = path

  remove_facet_query: (search_request, facet, value, options = {}) ->
    new_facet_queries = _.reject(search_request.facet_queries, (element) =>
      element["field"] == @parent.get("facet.field") && element["query"] == @get("term")
    )

    search_request.facet_queries = if new_facet_queries.length == 0 then undefined else new_facet_queries

  reset_from: (search_request) ->
    search_request.from = undefined # remove from to let server default it

  searches_path: (options = {}) ->
    @parent.searches_path(options)
