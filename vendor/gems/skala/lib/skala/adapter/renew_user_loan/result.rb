require_relative "../renew_user_loan"

class Skala::Adapter::RenewUserLoan::Result
  include Virtus.model

  attribute :source
end
