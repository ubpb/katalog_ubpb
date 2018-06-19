require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetContentType < Transformator::Transformation::Step

  def call
    target.record.content_type = transformation.read_source_values(".//display/type").first
  end
end
