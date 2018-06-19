require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::ElasticsearchAdapter::Search::RequestTransformation::
  AddAggregations < Transformator::Transformation::Step

  def call
    source.facets.try(:each) do |_facet|
      target["aggregations"] ||= {}

      elasticsearch_aggregation =
      if _facet.is_a?(Skala::Adapter::Search::Request::HistogramFacet)
        {
          "histogram" => {
            "field" => _facet.field,
            "interval" => _facet.interval
          }
          .compact
        }
      elsif _facet.is_a?(Skala::Adapter::Search::Request::RangeFacet)
        {
          "range" => {
            "field" => _facet.field,
            "ranges" => _facet.ranges.map do |_range|
              {
                "key" => _range.key,
                "from" => _range.from,
                "to" => _range.to
              }
              .compact
            end
          }  
        }
      elsif _facet.is_a?(Skala::Adapter::Search::Request::TermsFacet)
        {
          "terms" => {
            "field" => _facet.field,
            "size" => _facet.size,
            "shard_size" => (_facet.size * 3 if _facet.size)
          }
          .compact
        }
      end
      
      if elasticsearch_aggregation
        target["aggregations"][_facet.name] = elasticsearch_aggregation
      end
    end
  end
end
