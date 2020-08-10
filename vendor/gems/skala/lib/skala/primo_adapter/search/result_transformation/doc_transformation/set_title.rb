require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetTitle < Transformator::Transformation::Step

  def call
    title = transformation.read_source_values(".//display/title").first
    target.record.title =  ActionView::Base.full_sanitizer.sanitize(title, tags: %w(span))
  end
end
