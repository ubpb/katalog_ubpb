require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  SetOnCampus < Transformator::Transformation::Step

  def call
    transformation.inner_search_request.locate("onCampus").first.tap do |_node|
      _node << (transformation.on_campus.try(:to_s) == "true" ? "true" : "false")
    end
  end

end
