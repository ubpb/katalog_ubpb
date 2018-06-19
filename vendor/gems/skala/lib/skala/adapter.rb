require_relative "../skala"

module Skala
  class Adapter
    require_relative "adapter/operation"

    #
    # errors (must come before includes for operation to be able to derive own errors)
    #
    class Error < StandardError; end
    class BadRequestError < Error; end
    class RequestFailedError < Error; end

    # operations
    require_relative "./adapter/authenticate_user"
    require_relative "./adapter/create_user_hold_request"
    require_relative "./adapter/delete_user_hold_request"
    require_relative "./adapter/get_record_holdable_items"
    require_relative "./adapter/get_record_items"
    require_relative "./adapter/get_records"
    require_relative "./adapter/get_user"
    require_relative "./adapter/get_user_former_loans"
    require_relative "./adapter/get_user_hold_requests"
    require_relative "./adapter/get_user_inter_library_loans"
    require_relative "./adapter/get_user_loans"
    require_relative "./adapter/get_user_transactions"
    require_relative "./adapter/renew_user_loan"
    require_relative "./adapter/renew_user_loans"
    require_relative "./adapter/search"
    require_relative "./adapter/update_user"

    # TODO: all others are 'typed', e.g. get_user, get_record_items ... should this be typed, too ?
    def search(request, *args)
      request = request.is_a?(Search::Request) ? request : Search::Request.new(request)
      self.class::Search.new(self).call(request, *args)
    end

    #
    # records
    #
    def get_records(*args)
      self.class::GetRecords.new(self).call(*args)
    end

    #
    # record item(s)
    #
    def get_record_items(*args)
      self.class::GetRecordItems.new(self).call(*args)
    end

    def get_record_holdable_items(*args)
      self.class::GetRecordHoldableItems.new(self).call(*args)
    end

    #
    # user(s)
    #
    def authenticate_user(*args)
      self.class::AuthenticateUser.new(self).call(*args)
    end

    def get_user(*args)
      self.class::GetUser.new(self).call(*args)
    end

    def update_user(*args)
      self.class::UpdateUser.new(self).call(*args)
    end

    #
    # user cash
    #
    def get_user_cash(*args)
      self.class::GetUserCash.new(self).call(*args)
    end

    #
    # user hold request(s)
    #
    def create_user_hold_request(*args)
      self.class::CreateUserHoldRequest.new(self).call(*args)
    end

    def delete_user_hold_request(*args)
      self.class::DeleteUserHoldRequest.new(self).call(*args)
    end

    def get_user_hold_requests(*args)
      self.class::GetUserHoldRequests.new(self).call(*args)
    end

    #
    # user inter library loans
    #
    def get_user_inter_library_loans(*args)
      self.class::GetUserInterLibraryLoans.new(self).call(*args)
    end

    #
    # user loan(s)
    #
    def get_user_former_loans(*args)
      self.class::GetUserFormerLoans.new(self).call(*args)
    end

    def get_user_loans(*args)
      self.class::GetUserLoans.new(self).call(*args)
    end

    def renew_user_loan(*args)
      self.class::RenewUserLoan.new(self).call(*args)
    end

    def renew_user_loans(*args)
      self.class::RenewUserLoans.new(self).call(*args)
    end

    #
    # user transactions
    #
    def get_user_transactions(*args)
      self.class::GetUserTransactions.new(self).call(*args)
    end
  end
end
