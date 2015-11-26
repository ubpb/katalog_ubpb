require "skala/elasticsearch_adapter/search_records"
require_relative "../ubpb_elasticsearch_adapter"
require_relative "../record_mapper"

class KatalogUbpb::UbpbElasticsearchAdapter::SearchRecords < Skala::ElasticsearchAdapter::SearchRecords
  def call(search_request)
    search_request = search_request.deep_dup
    add_query_to_ignore_deleted_records!(search_request)

    search_result = super(search_request)
    set_hits!(search_result)

    search_result
  end

  private # search request transformation

  def add_query_to_ignore_deleted_records!(search_request)
    search_request.queries << Skala::SearchRequest::MatchQuery.new(query: "A", field: "status")
  end

  private # search result transformation

  def set_hits!(search_result)
    mapper = KatalogUbpb::RecordMapper.new

    search_result.hits = search_result.source["hits"]["hits"].map do |_hit|
      {
        id: _hit["_id"],
        index: _hit["_index"],
        record: mapper.map_record(_hit["_source"]),
        score: _hit["_score"],
        type: _hit["_type"]
      }
    end
  end



end
