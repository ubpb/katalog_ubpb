#= require component_helpers

((window.app ?= {}).components ?= {}).SortFieldSelect = Ractive.extend
    #
    # ractive
    #
    decorators:
      bootstrap_simple_select: (node) ->
        $(node).bootstrapSimpleSelect()
        return teardown: ->

    oncomplete: ->
      @fire("ready")

    onrender: ->
      @on "Change", (event) ->
        selected_sort_field = $(event.node).find("option:selected").attr("value")

        newly_created_search_request = _.chain(@get("search_request"))
          .cloneDeep()
          .tap (cloned_search_request) ->
            cloned_search_request["from"] = 0
            cloned_search_request["sort"] = [selected_sort_field]
          .value()

        path = @searches_path(search_request: newly_created_search_request)
        if Turbolinks? then Turbolinks.visit(path) else window.location.href = path

    #
    # custom
    #
    searches_path: (options = {}) ->
      app.ComponentHelpers.path_helper_factory(@get("searches_path"))(options)
