do(app = (window.App ?= {})) ->
  (app.decorators ?= {}).SelectableTable = Ractive.extend
    append: true

    onconfig: ->
      @set "select_mode", false
      @_select_control_class = "#{@_guid} select-control"
      @_select_control_selector = @_select_control_class.replace(/^|\s+/g, ".")

      @observe "select_mode", (new_value, old_value) ->
        if old_value? && new_value != old_value
          if new_value is true
            @_show_select_controls()
          else if new_value is false
            @_hide_select_controls()

    oninit: ->
      @_add_select_controls()

      $(@el).on "enable_select_mode", (event, preceding_event) =>
        preceding_event.preventDefault()
        event.stopPropagation()
        @set "select_mode", true

      $(@el).on "click", "[data-click-triggers]", (event) =>
        event.stopPropagation()
        @fire $(event.target).data("click-triggers"), event

      @on "DisableSelectMode", (event) =>
        event.preventDefault()
        @set "select_mode", false

      @on "Submit", =>
        event.preventDefault()
        @_submit_ids()

      @on "ToggleSelectAll", (event) =>
        tbody_checkboxes = $(@el).find("tbody #{@_select_control_selector} [type='checkbox']")

        if $(event.target).prop("checked")
          tbody_checkboxes.each (_index, _el) -> $(_el).prop("checked", true)
        else
          tbody_checkboxes.each (_index, _el) -> $(_el).prop("checked", false)

    _add_select_controls: ->
      table_columns_count = $(@el).find("tbody tr:first td").length

      # width: 1% and white-space: nowrap is for non-stretching column
      $(@el).find("tr").prepend """
        <td class="#{@_select_control_class}" style="display: none; width: 1%; white-space: nowrap;">
          <input type="checkbox">
        </td>
      """

      $(@el).append """
        <tfoot class="#{@_select_control_class}" style="display: none;">
          <tr>
            <td>
              <input data-click-triggers="ToggleSelectAll" type="checkbox">
            </td>
            <td colspan="#{table_columns_count - 1}">
              <button class="btn btn-danger" data-click-triggers="Submit">Merklisten löschen</button>
              <span>&nbsp;</span>
              <a class="btn btn-default" data-click-triggers="DisableSelectMode" href="#">Abbrechen</a>
            </td>
          </tr>
        </tfoot>
      """

    _hide_select_controls: ->
      $(@el).find(@_select_control_selector).hide()

    _show_select_controls: ->
      $(@el).find(@_select_control_selector).show()

    _submit_ids: ->
      ids = $(@el).find("tbody tr")
        .filter (_index, _el) =>
          $(_el).find(@._select_control_selector).find("input[type='checkbox']").prop("checked") is true
        .map (_index, _el) =>
          $(_el).data("id")
        .toArray() # because its still a jquery collection

      if ids.length > 0
        form = $(
          """
            <form action="#{@get("action")}" method="post">
              <input type="hidden" name="_method" value="#{@get('method')}">
              <input type="hidden" name="authenticity_token" value="#{@get('authenticity_token')}">
          """ +
          ids.map((_id) ->
            """
                <input type="hidden" name="ids[]" value="#{_id}">
            """
          ).join("\n") +
          """
            </form>
          """
        )

        form.submit()
      else
        @set "select_mode", false
