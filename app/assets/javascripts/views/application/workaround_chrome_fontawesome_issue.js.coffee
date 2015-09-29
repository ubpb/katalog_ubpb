#=require utils/singletonReadyOrPageChange

# (possbile) workaround for
# - https://github.com/FortAwesome/Font-Awesome/issues/2763
# - https://code.google.com/p/chromium/issues/detail?id=336170
app.utils.singletonReadyOrPageChange 'app.views.application.workaroundChromeFontawesomeIssue', ->
  $(".fa").addClass("chrome-fontaweseome-issue").removeClass("chrome-fontaweseome-issue")
