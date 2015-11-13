#= require app/path_helpers

((window.app ?= {}).components ?= {}).SortFieldSelect = Ractive.extend
  template: """
    <select decorator="bootstrap_simple_select" value="{{primary_sort_field}}" on-change="Change">
      {{#sortable_fields}}
        <option value="{{this[0]}}">{{this[1]}}</option>
      {{/sortable_fields}}
    </select>
  """

  decorators:
    bootstrap_simple_select: (node) ->
      $(node).bootstrapSimpleSelect()
      return teardown: ->

  onconfig: ->
    @set("primary_sort_field", @get("search_request.sort.0.field") || @get("sortable_fields")[0][0])

  onrender: ->
    @on "Change", (event) ->
      selected_sort_field = $(event.node).find("option:selected").attr("value")
      new_search_request = _.cloneDeep(@get("search_request"))

      if selected_sort_field != @get("sortable_fields")[0][0]
        new_search_request["sort"] = [{field: selected_sort_field}]
      else
        new_search_request["sort"] = undefined

      path = @searches_path(search_request: new_search_request)
      if Turbolinks? then Turbolinks.visit(path) else window.location.href = path

  #
  # custom
  #
  searches_path: (options = {}) ->
    app.PathHelpers.path_helper_factory(@get("searches_path"))(options)
