class RecordsController < ApplicationController
  #before_filter :set_page_title_addition, only: [:show] # for nicer browser page title

  def show
    @scope = current_scope

    if @search_request = search_request_from_params
      flash[:search_request] = @search_request.to_h
      return redirect_to(record_path(params[:id], scope: params[:scope]))
    elsif serialized_search_request = flash[:search_request]
      @search_request = Skala::SearchRequest.new(serialized_search_request)
    end

    @record = Skala::GetRecordService.call(
      adapter: @scope.search_engine_adapter.instance,
      id: params[:id]
    )

    binding.pry

    if @search_request
      temporary_search_request = @search_request.deep_dup
      temporary_search_request.from = (@search_request.from - 5) < 0 ? 0 : @search_request.from - 5
      temporary_search_request.size = @search_request.size + 5

      search_result = Skala::SearchRecordsService.call(
        adapter: @scope.search_engine_adapter.instance,
        search_request: temporary_search_request
      )
      
      @total_hits = search_result.total_hits
      
      if index = search_result.hits.find_index { |_hit| _hit.id == params[:id] }
        @position_within_search_result = index + @search_request.from
      else

      end

      binding.pry
    end

=begin
    @scope = Skala.config.find_search_scope(params[:scope])
    @ils_adapter = Skala.config.ils_adapter.instance # for translate

    if params[:search_request].present?
      @search_request = Skala::Search::Request.new(JSON.parse(params[:search_request]))

      @predecessors = params[:predecessors] == "null" ? nil : JSON.parse(params[:predecessors])
      @successors = params[:successors] == "null" ? nil : JSON.parse(params[:successors])

      @total_number_of_records = params[:total_number_of_records].to_i
      @position_within_search = 1 + @search_request.from + (@predecessors.try(:length) || 0)
    end

    @record = Skala::GetRecord.call(
      id: params[:id],
      search_engine_adapter: @scope.search_engine_adapter.instance
    ).decorate.tap do |decorated_record|
      decorated_record.scope = @scope
    end

    @items = if @ils_adapter # TODO: Check if the ILS Adapter can handle the current record id
      Skala::GetRecordItemsService.call(ils_adapter: @ils_adapter, record_id: params[:id])
    else
      []
    end.map! do |_item|
      _item.decorate.mtap(:scope=, @scope)
    end

    if current_user
      @notes = current_user.notes
      @watch_lists = current_user.watch_lists.includes(:entries)
    end

    set_title_addition(@record.title.first.truncate(80))

    respond_to do |format|
      format.bibtex { send_data(@record.to_bibtex, filename: "#{@record.id}.bib") }
      format.html
    end
=end
  end
end
