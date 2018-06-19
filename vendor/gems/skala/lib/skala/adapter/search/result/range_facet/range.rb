require_relative "../range_facet"

class Skala::Adapter::Search::Result::RangeFacet::Range
  include Virtus.model

  attribute :count, Integer, required: true
  attribute :from,  String
  attribute :key,   String,  required: true
  attribute :to
end
