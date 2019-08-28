class SearchesController < ApplicationController

  before_action { add_breadcrumb name: "searches#index" }

  def index
    if (@search_request = search_request_from_params).try(:queries).try(:any?) { |_query| _query.query.present? }
      # Make sure to redirect search request, that have been constructred from special isbn, issn and oclcid params.
      # See also: BaseController#search_request_from_params
      if params[:issn].present? || params[:isbn].present? || params[:oclc_id].present?
        redirect_to searches_path(search_request: @search_request, scope: params[:scope]) and return
      end

      if defined?(::NewRelic)
        ::NewRelic::Agent.add_custom_attributes(search_request: @search_request.as_json) # needs to be a hash
      end

      @search_result = SearchRecordsService.call(
        adapter: current_scope.search_engine_adapter.instance,
        facets: current_scope.facets,
        options: {
          on_campus: on_campus?(request.remote_ip)
        },
        search_request: @search_request
      )

      if @search_request.try(:changed?)
        flash[:notice] = t(".please_update_url")
        return redirect_to(searches_path(scope: current_scope, search_request: @search_request))
      end

      # For custom Piwik analytics
      # @see views/application/_piwik_tracking.html.slim
      @tracking_vars = {
        "search-scope" => current_scope.id,
        "facet-search" => @search_request.facet_queries.present?
      }
    else
      # In case of an empty search request, redirect back
      # to homepage.
      redirect_to(root_path(scope: params[:scope])) and return
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
