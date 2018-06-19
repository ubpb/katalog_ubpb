require_relative "../adapter"

class Skala::Adapter::RenewUserLoan < Skala::Adapter::Operation
  class RenewFailedError < Skala::Adapter::RequestFailedError; end

  require_relative "./renew_user_loan/result"
end
