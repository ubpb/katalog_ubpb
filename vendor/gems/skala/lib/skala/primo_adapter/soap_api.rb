require_relative "../primo_adapter"

class Skala::PrimoAdapter::SoapApi
  require_relative "./soap_api/search_brief"

  attr_accessor :adapter

  def initialize(adapter)
    self.adapter = adapter
  end

  def searchBrief(*args)
    self.class::SearchBrief.new(adapter).call(*args)
  end
end
