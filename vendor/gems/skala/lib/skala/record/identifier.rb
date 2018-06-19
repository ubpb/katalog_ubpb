require_relative "../record"

class Skala::Record::Identifier
  include Virtus.model

  attribute :type, String
  attribute :value, String

end
