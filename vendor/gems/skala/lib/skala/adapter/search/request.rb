require "json"
require "skala/adapter/operation/request"
require_relative "../search"

class Skala::Adapter::Search::Request < Skala::Adapter::Operation::Request
  # facets
  require_relative "./request/histogram_facet"
  require_relative "./request/range_facet"
  require_relative "./request/terms_facet"

  # queries
  require_relative "./request/ids_query"
  require_relative "./request/match_query"
  require_relative "./request/ordered_terms_query"
  require_relative "./request/query_string_query"
  require_relative "./request/range_query"
  require_relative "./request/simple_query_string_query"
  require_relative "./request/unscored_terms_query"

  # sort
  require_relative "./request/sort_request"

  # attributes
  attribute :facets,        Array[Facet],       lazy: true
  attribute :facet_queries, Array[Query],       lazy: true
  attribute :from,          Integer,            default: 0
  attribute :queries,       Array[Query],       required: true
  attribute :size,          Integer,            default: 25
  attribute :sort,          Array[SortRequest], lazy: true

  # be able to indicate, that this object was changed by an adapter
  def changed=(value)
    @changed = value
  end

  def changed?
    !!@changed
  end

  # override facet setter in order to determine facet type
  def facets=(value)
    if sanitized_value = [value].flatten(1).compact
      mapped_values = sanitized_value.map do |_element|
        _element.is_a?(Hash) ? self.class.facet_factory(_element) : _element
      end

      super(mapped_values)
    end
  end

  # override (facet_)queries setters in order to determine query type
  def facet_queries=(value)
    if sanitized_value = [value].flatten(1).compact
      mapped_values = sanitized_value.map do |_element|
        _element.is_a?(Hash) ? self.class.query_factory(_element) : _element
      end

      super(mapped_values)
    end
  end

  def queries=(value)
    if sanitized_value = [value].flatten(1).compact
      mapped_values = sanitized_value.map do |_element|
        _element.is_a?(Hash) ? self.class.query_factory(_element) : _element
      end

      super(mapped_values)
    end
  end

  #
  # helpers to implement facets/queries setters
  #
  def self.factory(postfix) # e.g. :facet or :query which turns to "#{type}_#{postfix}", e.g. "match_query" or "range_facet"
    -> (value) do
      class_name = "#{value[:type] || value["type"]}_#{postfix}".classify

      if const_defined?(class_name)
        const_get(class_name).new(value)
      else
        raise ArgumentError.new("Unknown #{postfix} type!")
      end
    end
  end

  def self.facet_factory(value)
    factory(:facet).call(value)
  end

  def self.query_factory(value)
    factory(:query).call(value)
  end

  # TODO: move to frontend
  def to_param(*)
    as_json.select { |_key, _value| _value.present? }.to_json
  end
end
