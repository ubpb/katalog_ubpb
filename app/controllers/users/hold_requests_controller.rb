class Users::HoldRequestsController < UsersController
  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb
  end, only: :index

  before_action -> { flash.keep }, only: :create

  def index
    ils_adapter = KatalogUbpb.config.ils_adapter.instance
    search_engine_adapter = KatalogUbpb.config.ils_adapter.scope.search_engine_adapter.instance
    @scope = KatalogUbpb.config.ils_adapter.scope

    @hold_requests = GetUserHoldRequestsService.call(
      adapter: ils_adapter,
      user: current_user
    )

    @search_result = SearchRecordsService.call(
      adapter: search_engine_adapter,
      search_request: @search_request = Skala::SearchRequest.new(
        queries: [
          {
            type: "ordered_terms",
            field: "id",
            terms: @hold_requests.map(&:record_id)
          }
        ],
        size: @hold_requests.length
      )
    )

    @records_by_id = @search_result.hits.each_with_object({}) do |_hit, _hash|
      _hash[_hit.fields["id"]] = _hit
    end
  end

  def create
    if ils_record_id = create_params[:ils_record_id]
      create_user_hold_request = CreateUserHoldRequestService.new(
        adapter: current_scope.ils_adapter.try(:instance),
        record_id: ils_record_id,
        user: current_user
      )

      if can?(:call, create_user_hold_request)
        if create_user_hold_request.call!.failed?
          if create_user_hold_request.errors[:call].include?(:already_requested)
            flash[:notice] = t(".already_requested")
          else
            flash[:error] = t(".failed")
          end
        end
      end
    end

    redirect_back_or_to(user_hold_requests_path)
  end

  def destroy
    if (hold_request_id = destroy_params[:id])
      delete_user_hold_request = DeleteUserHoldRequestService.new(
        adapter: current_scope.ils_adapter.try(:instance),
        id: hold_request_id,
        user: current_user
      )

      if can?(:call, delete_user_hold_request)
        if delete_user_hold_request.call!.succeeded?
          flash[:notice] = t(".succeeded")
        else
          if delete_user_hold_request.errors[:call].include?(:hold_request_missing)
            flash[:notice] = t(".hold_request_missing")
          else
            flash[:error] = t(".failed")
          end
        end
      end
    end

    redirect_to action: :index
  end


  #
  private
  #
  def create_params
    params.permit(:ils_record_id)
  end

  def destroy_params
    params.permit(:id)
  end

end
