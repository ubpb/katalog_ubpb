class Users::LoansController < UsersController
  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb
  end, only: :index

  def index
    @loans = Skala::User::LoanDecorator.decorate_collection Skala::GetUserLoansService.call({
      ils_adapter: KatalogUbpb.config.ils_adapter.instance,
      user_id: current_user.username
    })
  end

  def renew
    call_operation Skala::RenewUserLoanService.new(user: current_user, loan_id: params[:id]),
    on_error: -> (op)   { flash[:error] = t(".error") },
    on_success: -> (op) { flash[:success] = t(".success") }

    redirect_to action: :index
  end

  def renew_all
    call_operation Skala::RenewUserLoansService.new(user: current_user),
    on_error: -> (op)   { flash[:error] = t(".error") },
    on_success: -> (op) { flash[:success] = t(".success") }

    redirect_to action: :index
  end
end
