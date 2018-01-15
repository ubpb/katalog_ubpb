class GetUserInterLibraryLoansService < Servizio::Service
  include AdapterRelatedService
  include InstrumentedService
  include UserRelatedService

  attr_accessor :ils_adapter

  alias_method :adapter,  :ils_adapter
  alias_method :adapter=, :ils_adapter=

  validates_presence_of :ils_adapter
  validates_presence_of :ils_user_id

  def call
    ils_adapter.get_user_inter_library_loans(ils_user_id)
  rescue Skala::Adapter::Error
    errors.add(:call, :failed) and return nil
  end
end
