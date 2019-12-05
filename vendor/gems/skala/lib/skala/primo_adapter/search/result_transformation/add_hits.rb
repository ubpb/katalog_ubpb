require "transformator/transformation/step"
require_relative "../result_transformation"
require_relative "./doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::
  AddHits < Transformator::Transformation::Step

  def call
    target.hits = transformation.search_brief_response.xpath("//DOC").map do |_doc|
      self.class.module_parent::DocTransformation.new.call(_doc)
    end
  end
end
