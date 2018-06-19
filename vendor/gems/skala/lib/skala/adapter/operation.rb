require_relative "../adapter"

class Skala::Adapter::Operation
  require_relative "./operation/result"

  attr_accessor :adapter

  def initialize(adapter)
    @adapter = adapter
  end
end
