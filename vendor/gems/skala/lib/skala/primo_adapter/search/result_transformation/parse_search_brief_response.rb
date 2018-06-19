require "nokogiri"
require "transformator/transformation/step"
require_relative "../result_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::
  ParseSearchBriefResponse < Transformator::Transformation::Step

  def call
    transformation.search_brief_response =
    Nokogiri::XML(source)
    .remove_namespaces!
    .at_xpath("/Envelope/Body/searchBriefResponse/searchBriefReturn")
    .try(:text)
    .try do |_embedded_search_brief_response|
      Nokogiri::XML(_embedded_search_brief_response) { |config| config.noblanks }
      .remove_namespaces!
      .at_xpath("//SEGMENTS/JAGROOT/RESULT")
    end
  end
end
