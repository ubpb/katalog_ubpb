#= require utils/singletonReadyOrPageChange

app.utils.singletonReadyOrPageChange "app.views.searches.show.handleChangeSortSelectOnChange", ->
  $("#change-sort-select").change (e) =>
    e.preventDefault()
    # make IE happy with this (somewhat clumsy) construct
    Turbolinks.visit(new_search_path = $(e.currentTarget).find(":selected").first().data("searches-path"))
