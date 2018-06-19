require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetLanguage < Transformator::Transformation::Step

  def call
    target.record.language = transformation.read_source_values(".//display/language", split: ";")
  end
end
