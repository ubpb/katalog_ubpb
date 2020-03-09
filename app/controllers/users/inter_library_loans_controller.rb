class Users::InterLibraryLoansController < UsersController

  before_action { add_breadcrumb name: "users.inter_library_loans#index" }

  def index
    if async_content_request?(:inter_library_loans)
      ils_adapter = KatalogUbpb.config.ils_adapter.instance

      @inter_library_loans = GetUserInterLibraryLoansService.call(
        ils_adapter: ils_adapter,
        user: current_user,
      )
    else
      # regular index
    end
  end
end
