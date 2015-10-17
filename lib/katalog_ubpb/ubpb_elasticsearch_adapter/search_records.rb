require "skala/elasticsearch_adapter/search_records"
require_relative "../ubpb_elasticsearch_adapter"

class KatalogUbpb::UbpbElasticsearchAdapter::SearchRecords < Skala::ElasticsearchAdapter::SearchRecords
  def call(search_request)
    search_request = search_request.deep_dup
    add_query_to_ignore_deleted_records!(search_request)

    result = super(search_request)

    result
  end

  private # search request transformation

  def add_query_to_ignore_deleted_records!(search_request)
    search_request.queries << Skala::SearchRequest::MatchQuery.new(query: "A", field: "status")
  end

  private # seach result transformation

end
