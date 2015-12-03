require "skala/elasticsearch_adapter/search"
require_relative "../ubpb_elasticsearch_adapter"
require_relative "./record_factory"

class KatalogUbpb::UbpbElasticsearchAdapter::Search < Skala::ElasticsearchAdapter::Search
  def call(search_request, options = {})
    dupped_search_request = search_request.deep_dup
    add_query_to_ignore_deleted_records!(dupped_search_request)
    boost_creators_and_title!(dupped_search_request)

    search_result = super(dupped_search_request)
    set_hits!(search_result)

    search_result
  end

  private # search request transformation

  def add_query_to_ignore_deleted_records!(search_request)
    ignore_deleted_records_query = {
      type: "match",
      field: "status",
      query: "A"
    }

    if search_request.is_a?(Hash)
      (search_request[:queries] || search_request["queries"]).push(ignore_deleted_records_query)
    elsif search_request.respond_to?(:queries)
      search_request.queries = [search_request.queries, ignore_deleted_records_query].flatten(1)
    end
  end

  def boost_creators_and_title!(search_request)
    search_request.queries
    .select do |_query|
      _query.type == "simple_query_string"
    end
    .each do |_simple_query_string_query|
      if _simple_query_string_query.fields == ["_all"]
        _simple_query_string_query.fields.push("creator_contributor_search^2")
        _simple_query_string_query.fields.push("title_search^2")
      end
    end
  end

  private # search result transformation

  def set_hits!(search_result)
    search_result.hits.map! do |_hit|
      _hit.tap do |_hit|
        source_hit = search_result.source["hits"]["hits"].find { |_source_hit| _source_hit["_id"] == _hit.id }
        _hit.record = self.class.parent::RecordFactory.call(source_hit["_source"])
      end
    end
  end
end
