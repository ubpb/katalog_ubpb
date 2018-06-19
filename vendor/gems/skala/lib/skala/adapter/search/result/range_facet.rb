require_relative "../result"
require_relative "./facet"

class Skala::Adapter::Search::Result::RangeFacet < Skala::Adapter::Search::Result::Facet
  require_relative "./range_facet/range"
  
  include Virtus.model

  attribute :field,   String
  attribute :name,    String, required: true
  attribute :ranges,  Array[Range]
end
