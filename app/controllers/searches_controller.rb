class SearchesController < ApplicationController

  before_action -> do
    breadcrumbs.clear
    add_breadcrumb
  end, only: [:index]

  def index
    if (@search_request = search_request_from_params).present?
      @search_result = SearchRecordsService.call(
        adapter: current_scope.search_engine_adapter.instance,
        facets: current_scope.facets,
        options: {
          on_campus: on_campus?(request.remote_ip)
        },
        search_request: @search_request
      )

      # For custom Piwik analytics
      # @see views/application/_piwik_tracking.html.slim
      @tracking_vars = {
        "search-scope" => current_scope.id,
        "facet-search" => @search_request.facet_queries.present?
      }
    else
      # In case of an empty search request, redirect back
      # to homepage.
      redirect_to(root_path(scope: params[:scope]))
    end

     if current_user
       @notes       = GetUserNotesService.call(user: current_user)
       @watch_lists = GetUserWatchListsService.call(include: :watch_list_entries, user: current_user)
     end
  rescue Skala::Adapter::BadRequestError
    flash.now[:error] = t(".bad_request_error")
    render
  end

end
