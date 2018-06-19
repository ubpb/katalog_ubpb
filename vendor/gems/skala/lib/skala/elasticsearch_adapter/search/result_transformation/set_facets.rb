require "transformator/transformation/step"
require_relative "../result_transformation"

class Skala::ElasticsearchAdapter::Search::ResultTransformation::
  SetFacets < Transformator::Transformation::Step

  def call
    if result_aggregations = source["aggregations"]
      requested_facets = transformation.search_request.facets
      result_facets = []

      result_aggregations.each do |_key, _value|
        if requested_facet = requested_facets.find { |_facet| _facet.name == _key }

          result_facets <<
          if requested_facet.is_a?(Skala::Adapter::Search::Request::HistogramFacet)
            Skala::Adapter::Search::Result::HistogramFacet.new({
              field: requested_facet.field,
              name: _key,
              entries: _value["buckets"].map do |_bucket|
                {
                  count: _bucket["doc_count"],
                  key: _bucket["key"]
                }
              end
            })
          elsif requested_facet.is_a?(Skala::Adapter::Search::Request::TermsFacet)
            Skala::Adapter::Search::Result::TermsFacet.new({
              field: requested_facet.field,
              name: _key,
              terms: _value["buckets"].map do |_bucket|
                {
                  term: _bucket["key"],
                  count: _bucket["doc_count"]
                }
              end
            })
          elsif requested_facet.is_a?(Skala::Adapter::Search::Request::RangeFacet)
            Skala::Adapter::Search::Result::RangeFacet.new({
              field: requested_facet.field,
              name: _key,
              ranges: _value["buckets"].map do |_bucket|
                {
                  count: _bucket["doc_count"],
                  from: _bucket["from_as_string"],
                  key: _bucket["key"],
                  to: _bucket["to_as_string"]
                }
              end
            })
            .tap do |_facet| # sort ranges to be requested order
              _facet.ranges.sort! do |_range, _other_range|
                requested_facet.ranges.find_index { |__range| __range.key == _range.key } <=>
                requested_facet.ranges.find_index { |__range| __range.key == _other_range.key }
              end
            end
          end
        end
      end

      target.facets = result_facets if result_facets.present?
    end
  end
end
