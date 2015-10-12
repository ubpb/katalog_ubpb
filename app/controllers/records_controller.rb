class RecordsController < ApplicationController
  #before_filter :set_page_title_addition, only: [:show] # for nicer browser page title

  def show
    @scope = current_scope
    
    if @search_request = search_request_from_params
      flash[:search_request] = @search_request.to_h
      return redirect_to(record_path(params[:id], scope: @scope))
    elsif serialized_search_request = flash[:search_request]
      @search_request = Skala::SearchRequest.new(serialized_search_request)
    end

    @record = Skala::GetRecordService.call(
      adapter: @scope.search_engine_adapter.instance,
      id: params[:id]
    )

    unless @record
      flash[:error] = t(".record_unavailable")

      if @search_request
        return redirect_to(searches_path(search_request: @search_request))
      else
        return redirect_to(searches_path)
      end
    end
    
    if @search_request
      on_first_page = @search_request.from == 0
      offset = 1

      extended_search_request = @search_request.deep_dup
      extended_search_request.from = @search_request.from - offset unless on_first_page
      extended_search_request.size = @search_request.size + offset

      search_result = Skala::SearchRecordsService.call(
        adapter: @scope.search_engine_adapter.instance,
        search_request: extended_search_request
      )
      
      @total_hits = search_result.total_hits
      hits = on_first_page ? [nil].concat(search_result.hits) : search_result.hits

      if index = hits[1..search_result.hits.length].find_index { |_hit| _hit.id == @record.id }
        @position_within_search_result = index + @search_request.from

        @predecessor = hits[index + offset - 1]
        @predecessor_search_request = @search_request.deep_dup

        @successor = hits[index + offset + 1]
        @successor_search_request = @search_request.deep_dup

        if index == 0 && !on_first_page
          @predecessor_search_request.from = @search_request.from - @search_request.size
        end

        if index == @search_request.size - 1
          @successor_search_request.from = @search_request.from + @search_request.size
        end
      else
        flash[:error] = t(".record_missing_within_page")
        return redirect_to(searches_path(search_request: @search_request))
      end
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
