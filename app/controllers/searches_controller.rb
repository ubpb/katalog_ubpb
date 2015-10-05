class SearchesController < ApplicationController

  def show
    if params["query"].present?
      search(params["query"])
    end
  end

private

  def search(query_string)
    @search_request = Skala::SearchRequest.new(
      queries: { query: query_string }
    )

    @search_result = Skala::SearchRecordsService.new(
      adapter: scope.search_engine_adapter.instance,
      search_request: @search_request
    ).call


    # @facets, @hits, @adapter_search_request, @total_number_of_hits = Skala::SearchRecords.call(
    #   facets: @scope.defaults["facets"],
    #   request: request,
    #   search_engine_adapter: @scope.search_engine_adapter.instance,
    #   search_request: @search_request
    # )

    # # if the adapter has modified the search request
    # if @adapter_search_request != @search_request
    #   redirect_to(
    #     params
    #     .deep_dup
    #     .permit!
    #     .merge(search_request: @adapter_search_request)
    #     .to_h
    #   )
    # else
    #   @facets.map! do |facet|
    #     facet.decorate.tap do |decorated_facet|
    #       decorated_facet.scope = @scope
    #     end
    #   end

    #   @hits.map!(&:decorate).each do |_hit|
    #     _hit.scope = @scope
    #   end

    #   if current_user
    #     @notes       = current_user.try(:notes)
    #     @watch_lists = current_user.watch_lists.includes(:entries)
    #   end
    # end
  end

end
