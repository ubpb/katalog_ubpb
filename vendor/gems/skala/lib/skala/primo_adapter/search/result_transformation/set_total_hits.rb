require "transformator/transformation/step"
require_relative "../result_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::
  SetTotalHits < Transformator::Transformation::Step

  def call
    target.total_hits =
    transformation.search_brief_response.at_xpath("//DOCSET").try do |_docset|
      _docset.attr("TOTALHITS").to_i
    end
  end
end
