require_relative "../skala"
require_relative "./record"

class Skala::HoldRequest
  include Virtus.model

  attribute :id, String
  attribute :deleteable, Boolean, default: false
  attribute :place_in_queue, Integer, default: 0
  attribute :record_id, String
  attribute :creation_date, Date
  attribute :begin_request_date, Date
  attribute :end_request_date, Date
  attribute :begin_hold_date, Date
  attribute :end_hold_date, Date
  attribute :record, Skala::Record
  attribute :status, Symbol
  attribute :signature, String

  # Make sure nil values
  def place_in_queue=(value)
    super(value || 0)
  end

end
