class Api::V1::Scopes::SearchesController < Api::V1::ApplicationController
  def index
    scope = Application.config.find_scope(params[:scope_id])

    call_service(SearchRecordsService,
      adapter: scope.search_engine_adapter.instance,
      facets: params[:facets].downcase == "false" ? nil : scope.facets,
      options: {
        on_campus: on_campus?(request.remote_ip)
      },
      search_request: search_request_from_params,
      on_success: -> (_called_operation) do
        @search_result = _called_operation.result
        .to_hash
        .tap do |_hash|
          _hash.delete(:source)
        end
        .try do |_hash|
          _hash.as_json
        end
      end
    )
  end
end
