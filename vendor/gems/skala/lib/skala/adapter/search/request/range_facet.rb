require_relative "../request"
require_relative "./facet"

class Skala::Adapter::Search::Request::RangeFacet < Skala::Adapter::Search::Request::Facet
  require_relative "./range_facet/range"

  attribute :field,  String,       required: true
  attribute :name,   String,       required: true
  attribute :ranges, Array[Range], required: true
end
