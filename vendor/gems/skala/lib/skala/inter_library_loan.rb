require_relative "../skala"

class Skala::InterLibraryLoan
  include Virtus.model

  attribute :due_date, Date
  attribute :id, String
  attribute :order_id, String
  attribute :pickup_location, String
  attribute :record, Skala::Record
  #
  # Supported states:
  #
  # new
  # waiting_for_process
  # sent_to_supplier
  # cancelled
  # received_by_library
  # loaned_to_patron
  # returned_by_patron
  # closed
  #
  attribute :status, String
  attribute :update_date, Date

end
