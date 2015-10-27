class GetRecordService < Servizio::Service
  attr_accessor :adapter
  attr_accessor :id

  validates_presence_of :adapter
  validates_presence_of :id

  def call
    adapter.get_records(ids: [id]).records.select(&:found).first
  end
end
