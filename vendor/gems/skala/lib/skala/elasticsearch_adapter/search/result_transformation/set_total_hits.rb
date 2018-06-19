require "transformator/transformation/step"
require_relative "../result_transformation"

class Skala::ElasticsearchAdapter::Search::ResultTransformation::
  SetTotalHits < Transformator::Transformation::Step

  def call
    target.total_hits = source.try(:[], "hits").try(:[], "total")
  end
end
