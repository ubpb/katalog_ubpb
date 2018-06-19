require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetYearOfPublication < Transformator::Transformation::Step

  def call
    target.record.year_of_publication = transformation.read_source_values(".//display/creationdate").first
  end
end
