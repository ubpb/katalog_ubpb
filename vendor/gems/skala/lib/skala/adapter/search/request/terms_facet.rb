require_relative "../request"
require_relative "./facet"

class Skala::Adapter::Search::Request::TermsFacet < Skala::Adapter::Search::Request::Facet
  attribute :field, String, required: true
  attribute :name,  String, required: true
  attribute :size,  Integer, lazy: true
end
