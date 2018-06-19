require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetId < Transformator::Transformation::Step

  def call
    target.record.id = source.at_xpath(".//control/recordid").text().gsub(/\ATN_/, "").split(":").last
  end

end
