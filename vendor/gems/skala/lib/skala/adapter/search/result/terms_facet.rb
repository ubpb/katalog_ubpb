require_relative "../result"
require_relative "./facet"

class Skala::Adapter::Search::Result::TermsFacet < Skala::Adapter::Search::Result::Facet
  require_relative "./terms_facet/term"

  include Virtus.model

  attribute :field, String
  attribute :name,  String
  attribute :terms, Array[Term]

  # attr_accessor :i18n_key # TODO: remove
end
