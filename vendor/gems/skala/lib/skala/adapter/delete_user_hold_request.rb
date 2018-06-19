require_relative "../adapter"

class Skala::Adapter::DeleteUserHoldRequest < Skala::Adapter::Operation
  class HoldRequestMissingError < Skala::Adapter::RequestFailedError; end

  class Result < Skala::Adapter::Operation::Result; end
end
