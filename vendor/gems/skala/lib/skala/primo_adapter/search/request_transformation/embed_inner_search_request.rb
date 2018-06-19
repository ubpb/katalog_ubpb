require "ox"
require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  EmbedInnerSearchRequest < Transformator::Transformation::Step

  def call
    target.locate("*/searchRequestStr").first.tap do |searchRequestStr|
      searchRequestStr << Ox::CData.new(Ox.dump(transformation.inner_search_request))
    end
  end
end
