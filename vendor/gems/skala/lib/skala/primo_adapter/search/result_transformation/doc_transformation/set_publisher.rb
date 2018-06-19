require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetPublisher < Transformator::Transformation::Step

  def call
    target.record.publisher = transformation.read_source_values(".//display/publisher").first
  end
end
