require "skala/adapter/search/result"
require "transformator/transformation"
require_relative "../search"

class Skala::ElasticsearchAdapter::Search::ResultTransformation < Transformator::Transformation
  require_directory "#{File.dirname(__FILE__)}/result_transformation"

  attr_accessor :search_request

  def call(source, options = {})
    options[:target] ||= Skala::Adapter::Search::Result.new(source: source)
    @search_request = options[:search_request]
    super(source, options)
  end

  sequence [
    SetFacets,
    SetHits,
    SetTotalHits
  ]
end
