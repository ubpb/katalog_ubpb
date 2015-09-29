#= require utils/singletonReadyOrPageChange

app.utils.singletonReadyOrPageChange 'app.views.watch_lists.show.handleSortBySelectChange', ->
  $('select[id="sort_watch_list_entries_by"]').change (e) =>
    e.preventDefault()
    # make IE happy with this (somewhat clumsy) construct
    Turbolinks.visit(new_search_path = $(e.currentTarget).find(':selected').first().data('href'))
