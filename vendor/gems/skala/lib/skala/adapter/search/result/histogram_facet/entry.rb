require_relative "../histogram_facet"

class Skala::Adapter::Search::Result::HistogramFacet::Entry
  include Virtus.model

  attribute :count, Integer, required: true
  attribute :key,   String,  required: true
end
