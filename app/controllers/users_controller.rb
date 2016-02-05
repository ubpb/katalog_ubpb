class UsersController < ApplicationController
  rescue_from NotAuthorizedError do
    flash[:error] = t(".not_authorized_error")
    redirect_to user_path
  end

  before_action :authenticate!, except: [:events]
  before_action { add_breadcrumb name: "users#show", url: user_path }

  layout "user"

  def show
    @user = current_user
  end

  # Make sure some "before actions" are run AFTER the before_actions
  # from the child classes but before render.
  def render(*args)
    cash_balance
    super
  end

private

  def cash_balance
    ils_adapter = KatalogUbpb.config.ils_adapter.instance
    search_engine_adapter = KatalogUbpb.config.ils_adapter.scope.search_engine_adapter.instance

    transactions = GetUserTransactionsService.call(
      ils_adapter: ils_adapter,
      search_engine_adapter: search_engine_adapter,
      user: current_user,
      from_cache: true,
      max_cache_age: 2.hours
    )

    @cash_balance = transactions.cash_balance
  end

end
