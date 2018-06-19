require_relative "../record"

class Skala::Record::Link
  include Virtus.model

  attribute :label, String
  attribute :url, String

end
