require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  SetBulkSize < Transformator::Transformation::Step

  def call
    transformation.inner_search_request.locate("PrimoSearchRequest/BulkSize").first.tap do |_node|
      _node << source.size.to_s
    end
  end
end
