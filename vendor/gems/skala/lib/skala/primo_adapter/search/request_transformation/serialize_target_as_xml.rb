require "ox"
require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  SerializeTargetAsXml < Transformator::Transformation::Step

  def call
    self.target = Ox.dump(self.target, with_xml: true)
  end
end
