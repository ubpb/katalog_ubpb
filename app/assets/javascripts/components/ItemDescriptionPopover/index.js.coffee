((window.app ?= {}).components ?= {}).ItemDescriptionPopover = Ractive.extend
  #
  # ractive
  #
  decorators:
    bootstrap_popover: (node) ->
      $(node).popover()
      return teardown: ->
