require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetTitle < Transformator::Transformation::Step

  def call
    target.record.title = transformation.read_source_values(".//display/title").first
  end
end
