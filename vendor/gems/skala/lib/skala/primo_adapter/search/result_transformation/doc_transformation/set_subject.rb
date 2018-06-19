require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetSubject < Transformator::Transformation::Step

  def call
    target.record.subject = transformation.read_source_values(".//display/subject", split: ";")
  end
end
