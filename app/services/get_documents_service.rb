class GetDocumentsService < Servizio::Service
  include InstrumentedService

  attr_accessor :adapter
  attr_accessor :ids

  validates_presence_of :adapter
  validates_presence_of :ids

  def call
    adapter.get_documents(ids).select{|r| r.found == true}
  end
end
