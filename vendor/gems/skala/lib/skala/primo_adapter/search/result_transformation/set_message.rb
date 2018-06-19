require "transformator/transformation/step"
require_relative "../result_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::
  SetMessage < Transformator::Transformation::Step

  def call
    target.message = transformation.search_brief_response.at_xpath("//RESULT/ERROR").try do |_error|
      _error.attr("MESSAGE")
    end
  end
end
