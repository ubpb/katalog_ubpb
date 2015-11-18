class RecordsController < ApplicationController
  #before_filter :set_page_title_addition, only: [:show] # for nicer browser page title

  def show
    @scope = current_scope
    @referer_path = params[:referer_path]

    if @search_request = search_request_from_params
      flash[:search_request] = @search_request.to_h
      return redirect_to(record_path(request.query_parameters.except(:search_request)))
    elsif serialized_search_request = flash[:search_request]
      flash.keep(:search_request)
      @search_request = Skala::SearchRequest.new(serialized_search_request)
    end

    @record = GetRecordService.call(
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
      extended_search_request.size = @search_request.size + 2 * offset

      search_result = SearchRecordsService.call(
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

    record_id = @record.fields["id"]

    #
    # Items, hold requests, ...
    #
    # TODO: merge items() and holdable_items()
    #

    # Load all items for the current record
    @items = items(record_id)

    if current_user
      # Load all holdable items for the current record
      holdable_items = holdable_items(record_id)

      # How many hold requests waiting in queue for the current record
      # TODO: We are checking this on the items here. This works because our
      # Aleph is expanding the hold requestes from the record to the items. However,
      # the Skala API should abstract this on record level.
      @number_of_hold_requests = @items.try(:map, &:number_of_hold_requests).try(:max)

      # Load all hold requests for the current user
      hold_requests = hold_requests(from_cache: false)

      # Check if the current user has a hold request for the current record
      @hold_request = hold_requests.find{|hr| hr.record_id == record_id}

      # Check if the current user can create a hold request for the current record
      @can_create_hold_request = holdable_items.present? && @hold_request.blank?
    end

    #
    # Render
    #
    respond_to do |format|
      format.html
      format.json { render json: JSON.pretty_generate(@record.as_json) }
    end
  end

private

  def hold_requests(user: current_user, **options)
    options[:adapter] ||= current_scope.ils_adapter.try(:instance)
    options[:from_cache] == !!options[:from_cache]
    options[:max_cache_age] ||= 12.hours
    options[:user] ||= user

    GetUserHoldRequestsService.call(options)
  end

  def holdable_items(record_id, user: current_user, **options)
    options[:adapter] ||= current_scope.ils_adapter.try(:instance)
    options[:id] ||= record_id
    options[:user] ||= user

    GetRecordHoldableItemsService.call(options)
  end

  def items(record_id, **options)
    options[:adapter] ||= current_scope.ils_adapter.try(:instance)
    options[:id] ||= record_id

    GetRecordItemsService.call(options)
  end
end
