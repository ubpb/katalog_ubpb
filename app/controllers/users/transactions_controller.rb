class Users::TransactionsController < UsersController

  before_filter { add_breadcrumb name: "users.transactions#index" }

  def index
    ils_adapter = KatalogUbpb.config.ils_adapter.instance
    search_engine_adapter = KatalogUbpb.config.ils_adapter.scope.search_engine_adapter.instance
    @scope = KatalogUbpb.config.ils_adapter.scope

    @transactions = GetUserTransactionsService.call(
      ils_adapter: ils_adapter,
      search_engine_adapter: search_engine_adapter,
      user: current_user
    )
  end

end
