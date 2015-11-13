class SearchesController < ApplicationController
  before_action do
    if KatalogUbpb::PermalinkTranslator.recognizes?(params)
      new_params = KatalogUbpb::PermalinkTranslator.translate(params)
      redirect_to searches_path(new_params)
    end
  end

  def index
    if (@search_request = search_request_from_params).present?
      @search_result = SearchRecordsService.call(
        adapter: current_scope.search_engine_adapter.instance,
        facets: current_scope.facets,
        search_request: @search_request
      )
    else
      @search_request = Skala::SearchRequest.new({
        queries: Skala::SearchRequest::QueryStringQuery.new({
          default_field: current_scope.searchable_fields.first
        })
      })
    end

    # if current_user
    #   @notes       = current_user.try(:notes)
    #   @watch_lists = current_user.watch_lists.includes(:entries)
    # end
  rescue Skala::Adapter::BadRequestError
    flash.now[:error] = t(".bad_request_error")
    render
  end
end
