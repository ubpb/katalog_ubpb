require "ox"
require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  SetupInnerSearchRequest < Transformator::Transformation::Step

  #
  # setup inner search request that will be wrapped in a cdata element at the end
  #
  def call
    # we setup this skeleton instead of dynamic element creation because order matters with primo
    transformation.inner_search_request = Ox.parse(
      <<-xml
        <searchRequest xmlns="http://www.exlibris.com/primo/xsd/wsRequest" xmlns:uic="http://www.exlibris.com/primo/xsd/primoview/uicomponents">
          <PrimoSearchRequest xmlns="http://www.exlibris.com/primo/xsd/search/request">
            <RequestParams></RequestParams>
            <QueryTerms>
              <BoolOpeator>AND</BoolOpeator>
            </QueryTerms>
            <StartIndex></StartIndex>
            <BulkSize></BulkSize>
            <DidUMeanEnabled>false</DidUMeanEnabled>
            <HighlightingEnabled>false</HighlightingEnabled>
            <Languages></Languages>
            <Locations></Locations>
          </PrimoSearchRequest>
          <onCampus></onCampus>
          <institution></institution>
        </searchRequest>
      xml
    )
  end
end
