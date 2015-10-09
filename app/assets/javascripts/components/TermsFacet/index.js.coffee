#= require component_helpers
#= require ./term

((window.app ?= {}).components ?= {}).TermsFacet = Ractive.extend
    #
    # ractive
    #
    components:
      Term: app.components.TermsFacet.Term

    computed:
      can_be_collapsed: ->
        @get("facet.terms").length > @get("collapse_threshold")

    data:
      collapse_threshold: 5
      is_collapsed: true # initially the facet is collapsed

    onrender: ->
      @on "Collapse", -> @set("is_collapsed", true)
      @on "Decollapse", -> @set("is_collapsed", false)

    #
    # custom
    #
    decorated_facet: ->
      @get("facet")

    searches_path: (options = {}) ->
      app.ComponentHelpers.path_helper_factory(@get("searches_path"))(options)

    undecorated_facet: ->
      @get("facet.object")
