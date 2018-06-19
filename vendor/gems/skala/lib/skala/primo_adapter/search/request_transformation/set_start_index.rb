require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  SetStartIndex < Transformator::Transformation::Step

  def call
    transformation.inner_search_request.locate("PrimoSearchRequest/StartIndex").first.tap do |_node|
      _node << (source.from + 1).to_s
    end
  end
end
