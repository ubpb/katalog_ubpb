class SearchesController < ApplicationController
  before_action do
    if former_catalog_search?
      redirect_to_translated_searches_path
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
      @search_request = Skala::Adapter::Search::Request.new(
        queries: [{ type: "query_string", default_field: current_scope.searchable_fields.first }]
      )
    end

    # if current_user
    #   @notes       = current_user.try(:notes)
    #   @watch_lists = current_user.watch_lists.includes(:entries)
    # end
  rescue Skala::Adapter::BadRequestError
    flash.now[:error] = t(".bad_request_error")
    render
  end

  # only for compatibility with former implementation
  def show
    if (search = Search.find_by_hashed_id(params[:id])) && former_catalog_search?(query = search.query)
      redirect_to_translated_searches_path(query)
    else
      redirect_to searches_path
    end
  end

  private

  def former_catalog_search?(params = self.params)
    KatalogUbpb::PermalinkTranslator.recognizes?(params)
  end

  def redirect_to_translated_searches_path(params = self.params)
    new_params = KatalogUbpb::PermalinkTranslator.translate(params)
    flash[:notice] = t(".redirected_from_old_permalink")
    redirect_to searches_path(new_params)
  end
end
