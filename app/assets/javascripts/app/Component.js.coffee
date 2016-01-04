#= require app/path_helpers

do(app = (window.app ?= {})) ->
  app.Component = Ractive.extend
    isolated: true
    magic: false
    modifyArrays: false

    #
    # Proxy properties
    #
    # You can use proxy properties like this
    # data:
    #   foo: "proxy(some_component)"
    #   bar: "proxy(app.another_component:muff)"
    #
    onconstruct: (userOptions) ->
      for data in [userOptions.data, @constructor.defaults.data]
        for key, value of data || {}
          if /^proxy\(/.test(value)
            [origin, property] = value.match(/^proxy\(([^)]+)\)/)[1].split(":")
            property ?= key # if the origin property is not given, interpolate from key
            (@["_proxy_properties"] ?= {})[property] = origin
            delete data[key]

    onconfig: ->
      if @["_proxy_properties"]?
        for property, origin_identifier of @["_proxy_properties"]
          if (origin = eval("window.#{origin_identifier}"))? && origin.observe? && origin.get?
            origin.observe "#{property}.*", (oldValue, newValue, keypath) =>
              @set(keypath, origin.get(keypath), propagate_proxy_properties: false)

    set: (keypath, value, options = {}) ->
      if options["propagate_proxy_properties"] ?= true
        if (property = keypath.match(/^[^\.\[]+/)?[0])?
          object = @; while(object?["_proxy_properties"] || object?.parent)
            if (origin_identifier = object?["_proxy_properties"]?[property])?
              if (origin = eval("window.#{origin_identifier}"))?
                return origin.set(keypath, value)

            object = object.parent

      @_super(keypath, value)

    #
    # custom
    #
    _path_helper_factory: (path) ->
      app.PathHelpers.path_helper_factory(path)
