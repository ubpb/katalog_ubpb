require "ox"
require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  SetLocations < Transformator::Transformation::Step

  def call
    transformation.locations.each do |_location|
      transformation.inner_search_request.locate("PrimoSearchRequest/Locations").first.tap do |_node|
        _node << Ox.parse(
          <<-xml
            <uic:Location type="#{_location[:type]}" value="#{_location[:value]}"/>
          xml
        )
      end
    end
  end
end
