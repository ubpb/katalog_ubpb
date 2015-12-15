do(helper = (Ractive.defaults.data ?= {})) ->
  # inside component templates I18n.t does not work
  helper.t = (path, options = {}) ->
    if path[0] == "." && i18n_key = @get("i18n_key")
      I18n.t(i18n_key + path, options)
    else
      I18n.t(path, options)
