class Ils
  class RenewLoanResult < BaseStruct
    attribute :loan_id, Ils::Types::String
    attribute :success, Ils::Types::Bool.default(false)
  end
end
