require_relative "../skala"
require_relative "./record"

class Skala::Transaction
  include Virtus.model

  attribute :creation_date, Date
  attribute :description, String
  attribute :reason, Symbol
  attribute :type, Symbol # :credit, :debit
  attribute :value, Float
  attribute :record, Skala::Record
  attribute :signature, String
end
