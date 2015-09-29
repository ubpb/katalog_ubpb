#= require utils/singletonReadyOrPageChange

app.utils.singletonReadyOrPageChange 'app.views.application.setupPhoneSearchScopeSwitcher.js.coffee', ->
  $('.phone-search-scope-switcher').on 'change', 'select', (e) ->
    if (selectedScope = $(e.currentTarget).find(':selected').first().attr('value'))?
      if (selectedScopeUrl = $("a.#{selectedScope}-scope").attr('href'))?
        Turbolinks.visit(selectedScopeUrl)
