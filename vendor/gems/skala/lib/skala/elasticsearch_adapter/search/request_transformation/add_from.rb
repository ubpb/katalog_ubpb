require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::ElasticsearchAdapter::Search::RequestTransformation::
  AddFrom < Transformator::Transformation::Step

  def call
    target["from"] = source.from
  end
end
