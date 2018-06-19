require_relative "../skala"

class Skala::Loan
  include Virtus.model

  attribute :due_date,      Date
  attribute :fine,          Float
  attribute :id,            String, required: true
  attribute :loan_date,     Date
  attribute :record,        Skala::Record
  attribute :renewable,     Axiom::Types::Boolean
  attribute :returned_date, Date
  attribute :signature,     String # a loan references a specific item and needs a specific signature

  def renewable?
    renewable == true
  end
end
