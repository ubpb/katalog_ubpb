require "skala/adapter/search"
require_relative "../elasticsearch_adapter"

class Skala::ElasticsearchAdapter::Search < Skala::Adapter::Search
  require_relative "./search/request_transformation"
  require_relative "./search/result_transformation"

  def call(search_request, options = {})
    elasticsearch_request = {
      body: RequestTransformation.new.call(search_request),
      index: @adapter.index
    }.merge(options)

    elasticsearch_result = @adapter.elasticsearch_client.search(elasticsearch_request)

    ResultTransformation.new.call(elasticsearch_result, search_request: search_request)
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest
    raise Skala::Adapter::BadRequestError
  end
end
