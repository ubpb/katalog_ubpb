class GetRecordItemsService < Servizio::Service
  include InstrumentedService

  attr_accessor :adapter
  attr_accessor :id

  validates_presence_of :adapter
  validates_presence_of :id

  def call
    adapter.get_record_items(id).try(:items)
  rescue
    errors[:call] = :failed and return nil
  end
end
