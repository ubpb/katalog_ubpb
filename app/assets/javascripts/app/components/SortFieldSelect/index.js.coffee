#= require app/path_helpers

((window.app ?= {}).components ?= {}).SortFieldSelect = Ractive.extend
  template: """
    <div class="btn-group">
      <button class="btn btn-default dropdown-toggle" data-toggle="dropdown">{{{label(sort_request)}}}&nbsp;<i class="fa fa-caret-down"></i></button>
      <ul class="dropdown-menu">
        {{#sortable_fields}}
          <li>
            <a href="#" on-click="SelectSortOption">{{{label(this)}}}</a>
          </li>
        {{/sortable_fields}}
      </ul>
    </div>
  """

  data:
    label: (sort_request_or_field) ->
      result = [@translated_field(sort_request_or_field)]

      if @order(sort_request_or_field)
        result.push "(#{@translated_order(sort_request_or_field)})"

      result.join("&nbsp;")

  onconfig: ->
    @set "sort_request", if sort_request = @get("search_request.sort.0")
      field: sort_request["field"]
      order: sort_request["order"]
    else
      field: @field(@get("sortable_fields")[0])
      order: @order(@get("sortable_fields")[0])

  oninit: ->
    @on "SelectSortOption", (event) ->
      event.original.preventDefault()

      if @field(@get("sort_request")) != @field(event.context) || @order(@get("sort_request")) != @order(event.context)
        @set("sort_request", field: @field(event.context), order: @order(event.context))
        new_search_request = _.cloneDeep(@get("search_request"))
        new_search_request["sort"] = [_.omit(@get("sort_request"), _.isEmpty)]
        path = @searches_path(search_request: new_search_request)
        if Turbolinks? then Turbolinks.visit(path) else window.location.href = path

  #
  # custom
  #
  field: (obj) ->
    if typeof(obj) == "object"
      obj["field"] || Object.keys(obj)[0]
    else
      obj

  order: (obj) ->
    if typeof(obj) == "object"
      if "field" in Object.keys(obj)
        obj["order"]
      else
        obj[Object.keys(obj)[0]]

  searches_path: (options = {}) ->
    app.PathHelpers.path_helper_factory(@get("searches_path"))(options)

  translated_field: (sort_request_or_field) ->
    I18n.t(@get("i18n_key") + ".fields." + @field(sort_request_or_field))

  translated_order: (obj) ->
    I18n.t("app.components.SortFieldSelect." + @order(obj)) if @order(obj)
