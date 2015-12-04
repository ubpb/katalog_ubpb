class Api::V1::SearchesController < Api::V1::ApplicationController
  def index
    scope = current_scope
    ids   = [*params[:id]]

    search_request = search_request_from_params

    if search_request.present?
      search_result = SearchRecordsService.call(
        adapter: current_scope.search_engine_adapter.instance,
        facets: current_scope.facets,
        search_request: search_request
      )

      render json: search_result.to_json
    else
      render json: []
    end
  end

private

  def search_request_from_params
    if params[:search_request]
      JSON.parse(params[:search_request]).try do |_deserialized_search_request|
        Skala::Adapter::Search::Request.new(_deserialized_search_request)
      end
    end
  end

end
