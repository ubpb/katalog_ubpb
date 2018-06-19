require "transformator/transformation/step"
require_relative "../doc_transformation"

# TODO: UBPB transformation: Move to custom adapter
class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetFulltextAvailable < Transformator::Transformation::Step

  def call
    target.record.fulltext_available = transformation.read_source_values(".//delivery/fulltext").first != "no_fulltext"
  end

end
