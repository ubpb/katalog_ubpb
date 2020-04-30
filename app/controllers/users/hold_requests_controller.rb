class Users::HoldRequestsController < UsersController

  before_action { add_breadcrumb name: "users.hold_requests#index" }

  def index
    ils_adapter = KatalogUbpb.config.ils_adapter.instance
    search_engine_adapter = KatalogUbpb.config.ils_adapter.scope.search_engine_adapter.instance

    @hold_requests = GetUserHoldRequestsService.call(
      ils_adapter: ils_adapter,
      search_engine_adapter: search_engine_adapter,
      user: current_user,
    )

    @hold_requests = @hold_requests.sort_by(&:creation_date)
    @scope = current_scope
  end

  def create
    return_path = sanitize_return_path(params[:return_to]) || user_hold_requests_path

    if current_user.ilsusername.starts_with?("PE") || current_user.ilsusername.starts_with?("PZ")
      flash[:error] = "TODO"
      return redirect_to(return_path)
    end

    if record_id = create_params[:record_id]
      create_user_hold_request = CreateUserHoldRequestService.new(
        adapter: current_scope.ils_adapter.try(:instance),
        record_id: record_id,
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

    redirect_to(return_path)
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
          flash[:success] = t(".succeeded")
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
    params.permit(:record_id)
  end

  def destroy_params
    params.permit(:id)
  end

end
