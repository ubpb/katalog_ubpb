class RecordsController < ApplicationController

  def show
    @scope = current_scope
    @referer_path = params[:referer_path]

    if @search_request = search_request_from_params
      flash.keep
      flash[:search_request] = @search_request.to_h
      return redirect_to(record_path(request.query_parameters.except(:search_request)))
    elsif serialized_search_request = flash[:search_request]
      #flash.keep(:search_request)
      @search_request = Skala::Adapter::Search::Request.new(serialized_search_request)
    end

    add_breadcrumb name: "searches#index", url: searches_path(search_request: @search_request) if @search_request.present?
    add_breadcrumb name: "records#show"

    if defined?(::NewRelic) && @search_request.present?
      ::NewRelic::Agent.add_custom_attributes(search_request: @search_request.as_json) # needs to be a hash
    end

    get_records_result = GetRecordsService.call(
      adapter: @scope.search_engine_adapter.instance,
      ids: [params[:id]]
    )

    @record = get_records_result.first.try(:record)

    unless @record
      flash[:error] = t(".record_unavailable")

      if @search_request
        return redirect_to(searches_path(search_request: @search_request))
      else
        return redirect_to(searches_path)
      end
    end

    if current_user
      @notes = GetUserNotesService.call(user: current_user)
      @watch_lists = GetUserWatchListsService.call(include: :watch_list_entries, user: current_user)
    end

    if @search_request
      on_first_page = @search_request.from == 0
      offset = 1

      extended_search_request = @search_request.deep_dup
      extended_search_request.from = @search_request.from - offset unless on_first_page
      extended_search_request.size = @search_request.size + 2 * offset

      search_result = SearchRecordsService.call(
        adapter: @scope.search_engine_adapter.instance,
        search_request: extended_search_request,
        options: {
          on_campus: on_campus?(request.remote_ip)
        }
      )

      @total_hits = search_result.total_hits
      hits = on_first_page ? [nil].concat(search_result.hits) : search_result.hits

      if index = hits[1..search_result.hits.length].find_index { |_hit| _hit.record.id == @record.id }
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

    #
    # Items, hold requests, ...
    #
    # TODO: merge items() and holdable_items()
    #

    # Load all items for the current record
    @items = items(@record)
    if @items.try(:any?)
      # How many hold requests waiting in queue for the current record
      # TODO: We are checking this on the items here. This works because our
      # Aleph is expanding the hold requestes from the record to the items. However,
      # the Skala API should abstract this on record level.
      @number_of_hold_requests = @items.try(:map, &:number_of_hold_requests).try(:max)

      #
      # TODO: should we use a cache here?
      #
      if current_user
        # Load all holdable items for the current record
        holdable_items = holdable_items(@record.id)

        # Check if the current user has a hold request for the current record
        hold_requests = hold_requests(user: current_user)
        @hold_request = hold_requests.present? ? hold_requests.find { |_hold_request| _hold_request.record.id == @record.id } : nil

        # Check if the current user can create a hold request for the current record
        @can_create_hold_request = holdable_items.try(:count) > 0 && @hold_request.blank?
        # Vormerkungen sind nicht möglich, solange min. ein verfügbares ausleihbares Exemplar existiert
        @can_create_hold_request = false if @items.any?{ |i|
          (i.availability == :available && i.status == :available) ||
          (i.availability == :available && i.status == :reshelving)
        }
      end
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
    options[:user] ||= user

    GetUserHoldRequestsService.call(options)
  end

  def holdable_items(record_id, user: current_user, **options)
    options[:adapter] ||= current_scope.ils_adapter.try(:instance)
    options[:id] ||= record_id
    options[:user] ||= user

    GetRecordHoldableItemsService.call(options)
  end

  def items(record, **options)
    options[:adapter] ||= current_scope.ils_adapter.try(:instance)
    options[:record] ||= record

    GetRecordItemsService.call(options)
  end
end
