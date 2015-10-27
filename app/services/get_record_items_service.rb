class GetRecordItemsService < Servizio::Service
  attr_accessor :adapter
  attr_accessor :id

  validates_presence_of :adapter
  validates_presence_of :id

  def call
    adapter.get_record_items(id)
  end
end
