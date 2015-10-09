class SearchesController < ApplicationController
  rescue_from (MalformedSearchRequestError = Class.new(StandardError)) do
    redirect_to searches_path
  end

  def index
    if (@search_request = search_request_from_params).present?
      search_records = Skala::SearchRecordsService.new(
        adapter: current_scope.search_engine_adapter.instance,
        facets: current_scope.facets,
        search_request: @search_request
      )

      @search_result = search_records.tap(&:call).result
    else
      @search_request = Skala::SearchRequest.new({
        queries: Skala::SearchRequest::SimpleQueryStringQuery.new({
          field: current_scope.searchable_fields.first
        })
      })
    end

    # if current_user
    #   @notes       = current_user.try(:notes)
    #   @watch_lists = current_user.watch_lists.includes(:entries)
    # end
  end

  private

  def search_request_from_params
    if params[:search_request]
      JSON.parse(params[:search_request]).try do |_deserialized_search_request|
        Skala::SearchRequest.new(_deserialized_search_request)
      end
    end
  rescue
    raise MalformedSearchRequestError
  end
end
