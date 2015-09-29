((window.App ?= {}).Utils ?= {}).CssHelper = class
  @normalize: (css_string) ->
    css_string
    .replace(/\r\n|\n|\r|\s+/gm, "")
    .split(";")
    .filter (_string) -> !!_string
    .sort()
    .join("; ")
    .replace(/:/gm, ": ")
    .concat(";")
