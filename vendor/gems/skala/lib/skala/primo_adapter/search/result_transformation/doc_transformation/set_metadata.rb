require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetMetadata < Transformator::Transformation::Step

  def call
    target.id = source.attr("ID")
    target.index = source.attr("SEARCH_ENGINE")
    target.score = source.attr("RANK")
    target.type = "record"
  end
end
