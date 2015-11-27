class Users::TransactionsController < UsersController
  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb
  end, only: :index

  def index
    ils_adapter = KatalogUbpb.config.ils_adapter.instance
    search_engine_adapter = KatalogUbpb.config.ils_adapter.scope.search_engine_adapter.instance
    @scope = KatalogUbpb.config.ils_adapter.scope

    @transactions = GetUserTransactionsService.call(
      ils_adapter: ils_adapter,
      search_engine_adapter: search_engine_adapter,
      user: current_user,
    )
  end
end
