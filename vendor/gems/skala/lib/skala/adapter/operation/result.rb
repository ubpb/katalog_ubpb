require_relative "../operation"

class Skala::Adapter::Operation::Result
  include Virtus.model

  attribute :source
end
