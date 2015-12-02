class Api::V1::RecordsController < Api::V1::ApplicationController
  def index
    scope = current_scope
    binding.pry
  end

  def show
    scope = KatalogUbpb.config.find_search_scope(params[:scope])

    get_record = Skala::GetRecord.new({
      id: params[:id],
      search_engine_adapter: scope.search_engine_adapter
    })

    if can?(:call, operation = get_record)
      if operation.valid?
        if operation.call!.succeeded?
          record = operation.result

          respond_to do |format|
            format.bibtex do
              if params[:download].try(:downcase) == "true"
                send_data(record.to_bibtex, filename: "#{record.id}.bib")
              else
                render text: record.to_bibtex
              end
            end

            format.json do
              json = params[:pretty] == "true" ? JSON.pretty_generate(record.as_json) : record.to_json

              if params[:download].try(:downcase) == "true"
                send_data(json, filename: "#{record.id}.json")
              else
                render :json => json
              end
            end
          end
        else
          head operation.errors[:http_status].first || :internal_server_error
        end
      else
        head :bad_request
      end
    else
      head :unauthorized
    end
  end
end
