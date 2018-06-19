require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetDescription < Transformator::Transformation::Step

  def call
    target.record.description = transformation.read_source_values(".//display/description")
  end
end
