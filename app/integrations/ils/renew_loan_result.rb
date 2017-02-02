class Ils
  class RenewLoanResult < BaseStruct
    attribute :id, Ils::Types::String
    attribute :success, Ils::Types::Bool.default(false)
    attribute :new_due_date, Ils::Types::Date
  end
end
