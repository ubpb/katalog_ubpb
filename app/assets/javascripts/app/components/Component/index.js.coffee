#= require app/path_helpers

do(app = (window.app ?= {})) ->
  (app.components ?= {}).Component = Ractive.extend
    #
    # remember to call @_super(args) if you overwrite one of these
    #
    onconstruct: (userOptions) ->
      for key, value of userOptions?.data || {}
        if value == "memory_store"
          delete userOptions.data[key]
          @computed[key] = {
            get: ((_key) -> -> app.memory_store.get(_key))(key)
            set: ((_key) -> (newValue) -> app.memory_store.set(_key, newValue))(key)
          }
    
    #
    # custom
    #
    _path_helper_factory: (path) ->
      app.PathHelpers.path_helper_factory(path)
