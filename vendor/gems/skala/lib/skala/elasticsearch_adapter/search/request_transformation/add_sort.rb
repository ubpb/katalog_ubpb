require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::ElasticsearchAdapter::Search::RequestTransformation::
  AddSort < Transformator::Transformation::Step

  def call
    source.sort.try do |_sort_requests|
      target["sort"] ||= _sort_requests.map do |_sort_request|
        if _sort_request.order
          { _sort_request.field => { order: _sort_request.order } }
        else
          _sort_request.field
        end
      end
    end
  end
end
