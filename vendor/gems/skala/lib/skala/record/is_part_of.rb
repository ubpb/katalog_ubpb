require_relative "../record"

class Skala::Record::IsPartOf
  include Virtus.model

  attribute :superorder_id, String
  attribute :label, String
  attribute :label_additions, Array[String]
  attribute :volume_count, String

end
