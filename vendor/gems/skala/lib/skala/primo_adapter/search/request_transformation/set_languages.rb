require "ox"
require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  SetLanguages < Transformator::Transformation::Step

  def call
    transformation.languages.each do |_language|
      transformation.inner_search_request.locate("PrimoSearchRequest/Languages").first.tap do |_node|
        _node << Ox.parse("<Language>#{_language}</Language>")
      end
    end
  end
end
