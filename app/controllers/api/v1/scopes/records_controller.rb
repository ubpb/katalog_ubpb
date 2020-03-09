class Api::V1::Scopes::RecordsController < Api::V1::ApplicationController
  def show
    scope = KatalogUbpb.config.find_scope(params[:scope_id])
    record_ids = params[:id].split(",")

    call_service(GetRecordsService,
      adapter: scope.search_engine_adapter.instance,
      ids: record_ids,
      on_success: -> (_called_operation) do
        if _called_operation.result.none?
          head :not_found
        else
          @records = _called_operation.result.map(&:record)

          respond_to do |format|
            # TODO: add support for multiple records
            format.bibtex do
              bibtex = KatalogUbpb::BibtexExporter.call(@records.first)

              if params[:download].try(:downcase) == "true"
                send_data(bibtex, filename: "#{@records.first.id}.bib")
              else
                render text: bibtex
              end
            end

            format.json do
              rendered_template = render_to_string

              if params[:download].try(:downcase) == "true"
                filename = @records.length > 1 ? "records.json" : "#{@records.first.id}.json"
                send_data(rendered_template, filename: filename)
              else
                render :json => rendered_template
              end
            end
          end
        end
      end
    )
  end
end
