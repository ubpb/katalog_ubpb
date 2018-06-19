require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  SetInstitution < Transformator::Transformation::Step

  def call
    transformation.inner_search_request.locate("institution").first.tap do |node|
      node << transformation.institution
    end
  end
end
