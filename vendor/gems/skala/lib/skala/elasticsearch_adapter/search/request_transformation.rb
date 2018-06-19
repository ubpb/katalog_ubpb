require "transformator/transformation"
require_relative "../search"

class Skala::ElasticsearchAdapter::Search::RequestTransformation < Transformator::Transformation
  require_directory "#{File.dirname(__FILE__)}/request_transformation"

  def call(source, options = {})
    options[:target] ||= {}
    super(source, options)
  end

  sequence [
    AddAggregations,
    AddFrom,
    AddQuery,
    AddSize,
    AddSort,
    AddVersion
  ]
end
