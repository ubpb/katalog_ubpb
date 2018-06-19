require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetSource < Transformator::Transformation::Step

  def call
    target.record.source = transformation.read_source_values(".//display/source").first
  end
end
