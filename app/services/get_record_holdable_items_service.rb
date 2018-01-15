class GetRecordHoldableItemsService < Servizio::Service
  include AdapterRelatedService
  include InstrumentedService
  include RecordRelatedService
  include UserRelatedService

  attr_accessor :ils_adapter
  attr_accessor :record_id
  attr_accessor :search_engine_adapter

  alias_method :adapter,  :ils_adapter
  alias_method :adapter=, :ils_adapter=
  alias_method :id,  :record_id
  alias_method :id=, :record_id=

  validates_presence_of :ils_adapter
  validates_presence_of :ils_user_id
  validates_presence_of :record_id

  def call
    ils_adapter_result = ils_adapter.get_record_holdable_items(record_id, ils_user_id)
    update_records!(ils_adapter_result, search_engine_adapter)
    strip_source!(ils_adapter_result)
  rescue Skala::Adapter::Error
    errors.add(:call, :failed) and return nil
  end
end
