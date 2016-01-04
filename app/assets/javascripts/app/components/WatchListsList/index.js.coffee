#= require app/Component

do(app = (window.app ?= {})) ->
  (app.components ?= {}).WatchListsList = app.Component.extend
    computed:
      watch_list: ->
        @get("watch_lists").find (element) => element.id == @get("watch_list_id")

    data:
      watch_lists: "proxy(app.memory_store:watch_lists)"

    oninit: ->
      @observe "watch_lists.*", (oldValue, newValue, keypath) =>
        $(@append).find("[data-record-id]").each (index, element) =>
          unless !!(@get("watch_list.watch_list_entries").find (watch_list_entry) => watch_list_entry.record_id == $(element).data("record-id"))
            $(element).remove()
