require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::ElasticsearchAdapter::Search::RequestTransformation::
  AddVersion < Transformator::Transformation::Step

  def call
    target["version"] ||= true
  end
end
