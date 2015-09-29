((window.App ?= {}).components ?= {}).Note = Ractive.extend
  oninit: ->
    $(window).on "app:user:note:create.#{@_guid} app:user:note:update.#{@_guid}", (event, note) =>
      @set("note", note) if note.record_id == @get("record")?.id

    $(window).on "app:user:note:destroy.#{@_guid}", (event, note) =>
      @set("note", null) if note.record_id == @get("record")?.id

  onteardown: ->
    $(window).off ".#{@_guid}"

  template: """
    <div>
      {{#note}}
        <div style="{{style}}">
          <span class="label label-default">{{~/translations.note}}</span>
          <span style="font-style: italic; vertical-align: middle">{{value}}</span>
        </div>
      {{/note}}
    </div>
  """
