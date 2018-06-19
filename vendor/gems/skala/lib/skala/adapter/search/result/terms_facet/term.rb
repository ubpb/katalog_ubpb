require_relative "../terms_facet"

class Skala::Adapter::Search::Result::TermsFacet::Term
  include Virtus.model

  attribute :count, Integer, required: true
  attribute :term,  String,  required: true
end
