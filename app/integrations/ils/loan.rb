class Ils
  class Loan < BaseStruct
    attribute :id, Types::String
    attribute :loan_date, Types::Date
    attribute :due_date, Types::Date
    attribute :returned_date, Types::Date.optional
    attribute :renewable, Types::Bool.default(false)
    attribute :ill, Types::Bool.default(false)
    attribute :record, Record
  end
end
