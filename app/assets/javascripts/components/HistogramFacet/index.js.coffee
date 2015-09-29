#= require component_helpers
#= require jquery.sparkline
#= require jsonpath
#= require polyfills/Array_map
#= require polyfills/Array_reduce
#= require polyfills/Object_keys
#= require ./lower_key_input
#= require ./slider
#= require ./sparkline
#= require ./upper_key_input

((window.app ?= {}).components ?= {}).HistogramFacet = Ractive.extend
  #
  # ractive
  #
  components:
    lowerkeyinput: app.components.HistogramFacet.LowerKeyInput
    slider: app.components.HistogramFacet.Slider
    sparkline: app.components.HistogramFacet.Sparkline
    upperkeyinput: app.components.HistogramFacet.UpperKeyInput

  computed:
    can_be_rendered: ->
      @get("selected_by_search_request") || (@get("min_key")? && @get("max_key")?)

    deselect_path: ->
      unfacetted_search_request = _.cloneDeep @get("search_request")

      for range_query_parent in JSONPath({json: unfacetted_search_request, path: "$..range^^^"})
        _.remove range_query_parent, (query) =>
          query["range"]?[@undecorated_facet()["name"]]?

      @searches_path(search_request: unfacetted_search_request)

    selected_by_search_request: ->
      # JSONPath has to be nested because it does not find if given as one path
      JSONPath(
        json: JSONPath
          json: @get("search_request")
          path: "$.query..range"
        path: "$.[?(@.#{@undecorated_facet()["name"]})]"
      ).length > 0

  oncomplete: ->
    @fire("ready")

  onconfig: ->
    [entries, min_key, max_key] = @process_facet(@get("facet")) || []

    @set("entries", entries)
    @set("current_lower_key", min_key)
    @set("current_upper_key", max_key)
    @set("min_key", min_key)
    @set("max_key", max_key)

  onrender: ->
    # setup event handling
    @on "lowerkeyinput.keypress update_search_result upperkeyinput.keypress", (event) =>
      if event.name == "update_search_result" || event.original.which == 13
        @submit_search_request()
        false

    # check lower/upper key bounds on change
    @observe "current_lower_key current_upper_key", (new_value, old_value, keypath) =>
      new_value = parseInt(new_value)
      old_value = parseInt(old_value)

      if keypath == "current_lower_key"
        if new_value < @get("min_key") || new_value > @get("current_upper_key")
          @set("current_lower_key", old_value)

      else if keypath == "current_upper_key"
        if new_value > @get("max_key") || new_value < @get("current_lower_key")
          @set("current_upper_key", old_value)

  #
  # custom
  #
  process_facet: (facet) ->
    if facet?.entries?.length > 0
      # create key => count mapping to ease further processing
      key_count_mapping = facet.entries.reduce (hash, entry) ->
        hash[entry.key] = entry.count
        hash
      , {}

      # calculate min/max key
      if (parsed_integers = Object.keys(key_count_mapping).map (key) -> parseInt(key))?
        min_key = Math.min.apply(null, parsed_integers)
        max_key = Math.max.apply(null, parsed_integers)

      # make entries "continuous" by filling the gaps between min/max
      for key in [min_key..max_key]
        key_count_mapping[key] ?= 0

      # recreate entries array (now without "key gaps")
      entries = []

      for key, count of key_count_mapping
        entries.push count: count, key: key

      # sort entries ascending by key (especially for firefox)
      entries.sort (a,b) ->
        if a.key < b.key then -1 else if a.key == b.key then 0 else 1

      # return the calculated values
      return [entries, min_key, max_key]

  searches_path: (options = {}) ->
    app.ComponentHelpers.path_helper_factory(@get("searches_path"))(options)

  submit_search_request: ->
    # create a range query
    (range_query = { range: {}}).range[@undecorated_facet()["name"]] =
      gte: @get("current_lower_key")
      lte: @get("current_upper_key")

    facetted_search_request = _.chain(@get("search_request"))
      # clone the original search request to prevent modification
      .cloneDeep()

      # add the created range query
      .tap (cloned_search_request) ->
        cloned_search_request.query.bool.must.push(range_query)

      # reset pagination on the newly created search request
      .tap (cloned_search_request) ->
        cloned_search_request.from = 0

      # unchain the value
      .value()

    # GET the url
    (Turbolinks?.visit || (url) -> window.location.href = url)(
      @searches_path(search_request: facetted_search_request)
    )

  undecorated_facet: ->
    @get("facet.object")
