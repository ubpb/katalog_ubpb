class GetRecordsService < Servizio::Service
  include AdapterRelatedService
  include InstrumentedService
  include RecordRelatedService

  attr_accessor :adapter
  attr_accessor :ids

  validates_presence_of :adapter
  validates_presence_of :ids

  def ids=(value)
    @ids = [value].flatten.compact.presence
  end

  def call
    adapter_result = adapter.get_records(ids)
    strip_source!(adapter_result)
  rescue Skala::Adapter::Error
    errors[:call] = :failed and return nil
  end
end
