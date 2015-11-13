do(helper = (Ractive.defaults.data ?= {})) ->
  # inside component templates I18n.t does not work
  helper.t = (path, options = {})->
    I18n.t(path, options)
