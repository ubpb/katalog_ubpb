class Users::FormerLoansController < UsersController
  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb
  end, only: :index

  def index
    @former_loans = Skala::User::LoanDecorator.decorate_collection Skala::GetUserFormerLoansService.call({
      ils_adapter: Skala.config.ils_adapter.instance,
      user_id: current_user.username
    })
  end
end
