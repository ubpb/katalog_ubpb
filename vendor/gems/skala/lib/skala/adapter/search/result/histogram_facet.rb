require_relative "../result"
require_relative "./facet"

class Skala::Adapter::Search::Result::HistogramFacet < Skala::Adapter::Search::Result::Facet
  require_relative "./histogram_facet/entry"
  
  include Virtus.model

  attribute :entries, Array[Entry]
  attribute :field,   String
  attribute :name,    String, required: true
end
