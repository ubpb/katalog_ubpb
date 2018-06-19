class Skala::Item
  include Virtus.model

  attribute :availability, Symbol
  attribute :due_date, Date
  attribute :expected_date, Date
  attribute :location, String
  attribute :hold_request_can_be_created, Boolean
  attribute :id, String
  attribute :item_status, String
  attribute :note, Array[String]
  attribute :number_of_hold_requests, Integer, default: 0
  attribute :status, Symbol, default: :unknown
  attribute :record, Skala::Record
end
