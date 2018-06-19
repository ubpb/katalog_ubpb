require_relative "../search"

class Skala::Adapter::Search::Result < Skala::Adapter::Operation::Result
  include Enumerable
  include Virtus.model

  # facets
  require_relative "./result/facet"
  require_relative "./result/histogram_facet"
  require_relative "./result/range_facet"
  require_relative "./result/terms_facet"

  # other
  require_relative "./result/hit"

  attribute :facets,     Array[Facet], lazy: true
  attribute :hits,       Array[Hit],   lazy: true
  attribute :total_hits, Integer,      default: 0
  attribute :message,    String

  def each
    block_given? ? hits.each { |_element| yield _element } : hits.each
  end
end
