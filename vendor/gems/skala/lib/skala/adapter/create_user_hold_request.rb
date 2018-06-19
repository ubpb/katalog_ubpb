require_relative "../adapter"

class Skala::Adapter::CreateUserHoldRequest < Skala::Adapter::Operation
  class AlreadyRequestedError < Skala::Adapter::RequestFailedError; end

  require_relative "./create_user_hold_request/result"
end
