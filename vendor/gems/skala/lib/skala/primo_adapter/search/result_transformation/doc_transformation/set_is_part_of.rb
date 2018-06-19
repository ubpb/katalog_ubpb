require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetIsPartOf < Transformator::Transformation::Step

  def call
    is_part_of = transformation.read_source_values(".//display/ispartof").map do |superorder|
      { label: superorder }
    end

    target.record.is_part_of = is_part_of
  end
end
