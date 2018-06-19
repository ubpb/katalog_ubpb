require "skala/loan"
require_relative "../renew_user_loans"

class Skala::Adapter::RenewUserLoans::Result
  include Virtus.model

  attribute :renewed_loans, Array[Skala::Loan]
  attribute :source
end
