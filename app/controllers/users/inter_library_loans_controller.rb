class Users::InterLibraryLoansController < UsersController
  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb
  end, only: :index

  def index
    if async_content_request?(:inter_library_loans)
      ils_adapter = Application.config.ils_adapter.instance

      @inter_library_loans = GetUserInterLibraryLoansService.call(
        ils_adapter: ils_adapter,
        user: current_user,
      )
    else
      # regular index
    end
  end
end
