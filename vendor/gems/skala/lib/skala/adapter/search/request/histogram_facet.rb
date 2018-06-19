require_relative "../request"
require_relative "./facet"

class Skala::Adapter::Search::Request::HistogramFacet < Skala::Adapter::Search::Request::Facet
  attribute :field,    String,  required: true
  attribute :interval, Integer, default: 1
  attribute :name,     String,  required: true
end
