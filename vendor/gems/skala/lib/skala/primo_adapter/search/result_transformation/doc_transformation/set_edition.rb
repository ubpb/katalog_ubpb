require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetEdition < Transformator::Transformation::Step

  def call
    target.record.edition = transformation.read_source_values(".//display/edition").first
  end
end
