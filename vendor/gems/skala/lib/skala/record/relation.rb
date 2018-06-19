require_relative "../record"

class Skala::Record::Relation
  include Virtus.model

  attribute :target_id, String
  attribute :label, String

end
