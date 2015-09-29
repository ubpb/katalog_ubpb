class Api::V1::RecordsController < Api::V1::ApplicationController
  def index
    @scope = Scope.find(params[:scope])
    @search_request = Search::Request.new(params[:search_request])

    @facets, @hits, @total_number_of_hits =
    SearchRecords.call(
      search_engine_adapter: @scope.search_engine_adapter,
      search_request: @search_request
    )

    # for debugging
    #json_string = render_to_string formats: :json
    #json_object = JSON.parse(json_string)
    #render :json => JSON.pretty_generate(json_object)
  end

  def show
    scope = Skala.config.find_search_scope(params[:scope])

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
