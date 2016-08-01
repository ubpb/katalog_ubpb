class Users::FormerLoansController < UsersController

  before_action { add_breadcrumb name: "users.former_loans#index" }

  def index
    if async_content_request?(:former_loans)
      ils_adapter = KatalogUbpb.config.ils_adapter.instance
      search_engine_adapter = KatalogUbpb.config.ils_adapter.scope.search_engine_adapter.instance

      @former_loans = GetUserFormerLoansService.call(
        ils_adapter: ils_adapter,
        limit: @limit = 100,
        search_engine_adapter: search_engine_adapter,
        user: current_user,
      )

      @former_loans = @former_loans.sort_by(&:returned_date).reverse
      @scope = current_scope
    end
  end
end
