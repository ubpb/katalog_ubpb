#= require app/Component

do(app = (window.app ?= {})) ->
  (app.components ?= {}).Note = app.Component.extend
    computed:
      i18n_key: -> "Note"
      note: -> @get("notes")?.find (element) => element?.record_id == @get("record.id")

    onteardown: ->
      $(window).off ".#{@_guid}"

    template: """
      <div>
        {{#note}}
          <div style="{{style}}">
            <!--<span class="label label-default">{{t(".note")}}</span>-->
            <span style="font-style: italic; vertical-align: middle">{{value}}</span>
          </div>
        {{/note}}
      </div>
    """
