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


=begin
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
=end
end
