require_relative "../range_facet"

class Skala::Adapter::Search::Request::RangeFacet::Range
  include Virtus.model

  attribute :from, BasicObject, lazy: true
  attribute :key,  String,      required: true
  attribute :to,   BasicObject, lazy: true
end
