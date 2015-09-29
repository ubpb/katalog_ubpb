class Users::InterLibraryLoansController < UsersController
  def index
    call_operation Users::GetInterLibraryLoans.new(user: current_user),
    on_success: -> (op) do
      @inter_library_loans = User::InterLibraryLoanDecorator.decorate_collection(op.result)
    end
  end
end
