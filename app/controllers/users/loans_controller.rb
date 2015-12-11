class Users::LoansController < UsersController
  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb
  end, only: :index

  def index
    if async_content_request?(:loans)
      ils_adapter = KatalogUbpb.config.ils_adapter.instance
      search_engine_adapter = KatalogUbpb.config.ils_adapter.scope.search_engine_adapter.instance

      @loans = GetUserLoansService.call(
        ils_adapter: ils_adapter,
        search_engine_adapter: search_engine_adapter,
        user: current_user,
      )

      @loans = @loans.sort_by(&:due_date)
      @scope = current_scope
    else
      # regular index
    end
  end

  def renew
    if (loan_id = renew_params[:id])
      renew_user_loan = RenewUserLoanService.new(
        adapter: current_scope.ils_adapter.try(:instance),
        loan_id: loan_id,
        user: current_user
      )

      if can?(:call, renew_user_loan)
        if renew_user_loan.call!.succeeded?
          flash[:success] = t(".succeeded")
        else
          flash[:error] = t(".failed")
        end
      end
    end

    redirect_to action: :index
  end

  def renew_all
    renew_all_user_loans = RenewAllUserLoansService.new(
      adapter: current_scope.ils_adapter.try(:instance),
      user: current_user
    )

    if can?(:call, renew_all_user_loans)
      if renew_all_user_loans.call!.succeeded?
        flash[:success] = t(".succeeded")
      else
        if renew_all_user_loans.errors[:call].include?(:not_all_loans_could_be_renewed)
          flash[:warning] = t(".not_all_loans_could_be_renewed") # .result contains the ones that could be renewed
        else
          flash[:error] = t(".failed")
        end
      end
    end

    redirect_to action: :index
  end

  private

  def renew_params
    params.permit(:id)
  end

end
