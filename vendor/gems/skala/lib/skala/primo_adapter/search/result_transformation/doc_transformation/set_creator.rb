require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetCreator < Transformator::Transformation::Step

  def call
    target.record.creator = transformation.read_source_values(".//display/creator", split: ";")
  end
end
