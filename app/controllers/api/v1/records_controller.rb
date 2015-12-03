class Api::V1::RecordsController < Api::V1::ApplicationController
  def index
    scope = current_scope
    ids   = [*params[:id]]

    get_records_result = GetRecordsService.call(
      adapter: scope.search_engine_adapter.instance,
      ids: ids
    )

    render json: get_records_result.to_json
  end

  def show
    scope = current_scope

    get_records_result = GetRecordsService.call(
      adapter: scope.search_engine_adapter.instance,
      ids: params[:id]
    ).first

    render json: get_records_result.to_json
  end
end
