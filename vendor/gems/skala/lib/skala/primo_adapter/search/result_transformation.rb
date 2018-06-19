require "transformator/transformation"
require_relative "../search"

class Skala::PrimoAdapter::Search::ResultTransformation < Transformator::Transformation
  require_directory "#{File.dirname(__FILE__)}/result_transformation"

  attr_accessor :search_brief_response
  attr_accessor :search_request

  def call(source, options = {})
    options[:target] ||= Skala::Adapter::Search::Result.new(source: source)
    @search_request = options[:search_request]
    super(source, options)
  end

  sequence [
    ParseSearchBriefResponse,
    SetTotalHits,
    SetMessage,
    [ # facets
      SetFacets,
      FixPrimoFacetsBugs,  # requires SetFacets to be run
      SortTermsFacetsTerms # requires all sanitations to be run
      #SortFacetsBySearchRequest,
      #RemoveFacetsIfEmpty,
      #ChangeFacetCreationdateToHistogramFacet,
      #SanitizeCreationdateFacet
    ],
    AddHits
  ]
end
