class SearchesController < ApplicationController
  rescue_from (MalformedQueryError = Class.new(StandardError)) do
    redirect_to searches_path
  end

  def index
    if (queries = queries_from_params).present?
      @search_request = Skala::SearchRequest.new({
        queries: queries
      })

      search_records = Skala::SearchRecordsService.new(
        adapter: current_scope.search_engine_adapter.instance,
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

  def queries_from_params
    if params[:queries]
      JSON.parse(params[:queries])
      .map do |_query|
        Skala::SearchRequest::SimpleQueryStringQuery.new(_query)
      end
      .presence
    end
  rescue
    raise MalformedQueryError
  end
end
