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
    redirect_back_or_to(user_hold_requests_path)
  end

  def destroy
    (destroy_params[:ids] || [destroy_params[:id].compact]).each do |_id|
      Skala::DeleteUserHoldRequestService.call({
        hold_id: _id,
        ils_adapter: KatalogUbpb.config.ils_adapter.instance,
        user_id: current_user.username
      })
    end

    redirect_to action: :index
  end


  #
  private
  #
  def destroy_params
    params.tap do |_params|
      _params[:ids] = _params[:ids].keys if _params[:ids].is_a?(Hash)
    end
  end
end
