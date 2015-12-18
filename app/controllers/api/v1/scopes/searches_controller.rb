class Api::V1::Scopes::SearchesController < Api::V1::ApplicationController
  def index
    scope = Application.config.find_scope(params[:scope_id])

    call_service(SearchRecordsService,
      adapter: scope.search_engine_adapter.instance,
      facets: params[:facets].try(:downcase) == "false" ? nil : scope.facets,
      options: {
        on_campus: on_campus?(request.remote_ip)
      },
      search_request: search_request_from_params,
      on_success: -> (_called_operation) do
        @search_result = _called_operation.result

        unless params[:source].try(:downcase) == "true"
          @search_result.source = nil
        end
      end
    )
  end
end
