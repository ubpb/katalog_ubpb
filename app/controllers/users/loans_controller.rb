class Users::LoansController < UsersController

  before_action { add_breadcrumb name: "users.loans#index" }

  def index
    if async_content_request?(:loans)
      @loans = Ils[:local].get_current_loans(current_user.ilsuserid)
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
        if renew_all_user_loans.errors[:base]&.find{|e| e.include?("not_all_loans_could_be_renewed")}
          flash[:notice] = t(".not_all_loans_could_be_renewed") # .result contains the ones that could be renewed
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
