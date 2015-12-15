do(app = (window.app ?= {})) ->
  (app.components ?= {}).MemoryStore = Ractive.extend
    oninit: ->
      $(document).ready =>
        # do not reinitialize on turbolinks page changes
        unless @get("initialized")
          if (initial_data = $("#memory-store-initial-data").text())?.length > 0
            @set(JSON.parse(initial_data)).then =>
              @set("initialized", true)

  #
  #
  #
  app.memory_store = new app.components.MemoryStore
