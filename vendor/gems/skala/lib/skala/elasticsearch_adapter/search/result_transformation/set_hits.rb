require "transformator/transformation/step"
require_relative "../result_transformation"

class Skala::ElasticsearchAdapter::Search::ResultTransformation::
  SetHits < Transformator::Transformation::Step

  def call
    target.hits = source["hits"]["hits"].map do |_hit|
      {
        id: _hit["_id"],
        index: _hit["_index"],
        score: _hit["_score"],
        type: _hit["_type"],
        version: _hit["_version"]
      }
    end
  end
end
