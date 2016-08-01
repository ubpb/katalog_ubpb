class Users::TransactionsController < UsersController

  before_action { add_breadcrumb name: "users.transactions#index" }

  def index
    @scope = KatalogUbpb.config.ils_adapter.scope
    @transactions = transactions(from_cache: false)
  end

end
