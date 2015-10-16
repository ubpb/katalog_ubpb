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
      new_search_request = _.cloneDeep(@get("search_request"))
      @remove_facet_query(new_search_request)
      @reset_from(new_search_request)
      @searches_path(search_request: new_search_request)

    selected_by_search_request: ->
      !!(@get("search_request.facet_queries")?.find (element) => element.field == @get("facet.field"))

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

  remove_facet_query: (search_request) ->
    if search_request.facet_queries
      search_request.facet_queries = _.reject(search_request.facet_queries, (element) =>
        element.field == @get("facet.field")
      )

    search_request

  reset_from: (search_request) ->
    search_request.from = undefined # remove from to let server default it

  searches_path: (options = {}) ->
    app.ComponentHelpers.path_helper_factory(@get("searches_path"))(options)

  submit_search_request: ->
    if @get("current_lower_key") != @get("min_key") || @get("current_upper_key") != @get("max_key")
      new_search_request = _.cloneDeep(@get("search_request"))
      new_search_request.facet_queries ?= []
      @remove_facet_query(new_search_request)
      @reset_from(new_search_request)

      new_search_request.facet_queries.push({
        field: @get("facet.field"),
        gte: @get("current_lower_key"),
        lte: @get("current_upper_key"),
        type: "range"
      })

      path = @searches_path(search_request: new_search_request)
      if Turbolinks? then Turbolinks.visit(path) else window.location.href = path
