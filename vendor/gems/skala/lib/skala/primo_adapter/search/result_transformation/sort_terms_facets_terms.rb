require "transformator/transformation/step"
require_relative "../result_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::
  SortTermsFacetsTerms < Transformator::Transformation::Step

  def call
    target.facets.each do |_target_facet|
      if _target_facet.type.to_s == "terms"
        _target_facet.terms.sort_by!(&:count).reverse!
      end
    end
  end
end
