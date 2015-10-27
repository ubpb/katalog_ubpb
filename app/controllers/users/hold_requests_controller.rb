class Users::HoldRequestsController < UsersController
  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb
  end, only: :index

  def index
    @hold_requests = Skala::User::HoldRequestDecorator.decorate_collection Skala::GetUserHoldRequestsService.call({
      ils_adapter: KatalogUbpb.config.ils_adapter.instance,
      user_id: current_user.username
    })
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

  def events
    render "#{action_name}_#{params[:id]}"
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
