require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::ElasticsearchAdapter::Search::RequestTransformation::
  AddSize < Transformator::Transformation::Step

  def call
    source.size.try do |_size|
      target["size"] = _size
    end
  end
end
