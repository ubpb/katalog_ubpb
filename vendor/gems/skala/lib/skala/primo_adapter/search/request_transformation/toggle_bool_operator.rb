require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  ToggleBoolOperator < Transformator::Transformation::Step

  def call
    if source.queries.present? && source.queries.all? { |_query| _query.type.to_sym == :ids }
      bool_opeator_node = transformation.inner_search_request.locate("PrimoSearchRequest/QueryTerms/BoolOpeator").first
      bool_opeator_node.nodes.clear << "OR"
    end
  end
end
