require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  EnableCDI < Transformator::Transformation::Step

  def call
    if transformation.enable_cdi
      transformation.inner_search_request.locate("PrimoSearchRequest/RequestParams").first.tap do |node|
        node << Ox.parse('<RequestParam key="searchCDI">true</RequestParam>')
      end
    end
  end
end


