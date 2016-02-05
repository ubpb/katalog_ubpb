class GetUserTransactionsService < Servizio::Service
  include AdapterRelatedService
  include InstrumentedService
  include RecordRelatedService
  include UserRelatedService

  attr_accessor :ils_adapter
  attr_accessor :search_engine_adapter

  alias_method  :adapter,  :ils_adapter
  alias_method  :adapter=, :ils_adapter=

  validates_presence_of :ils_adapter
  validates_presence_of :ilsuserid

  def call
    ils_adapter_result = ils_adapter.get_user_transactions(ilsuserid)
    update_records!(ils_adapter_result, search_engine_adapter)
    strip_source!(ils_adapter_result)
  rescue Skala::Adapter::Error
    errors[:call] = :failed and return nil
  end
end
