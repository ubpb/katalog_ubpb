class GetRecordService < Servizio::Service
  include InstrumentedService

  attr_accessor :adapter
  attr_accessor :id

  validates_presence_of :adapter
  validates_presence_of :id

  def call
    adapter.get_records(ids: [id]).records.select(&:found).first
  end
end
