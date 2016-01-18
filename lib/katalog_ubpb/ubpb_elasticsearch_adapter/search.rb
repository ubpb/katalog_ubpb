require "skala/elasticsearch_adapter/search"
require_relative "../ubpb_elasticsearch_adapter"
require_relative "./record_factory"

class KatalogUbpb::UbpbElasticsearchAdapter::Search < Skala::ElasticsearchAdapter::Search
  def call(search_request, options = {})
    dupped_search_request = search_request.deep_dup
    add_query_to_ignore_deleted_records!(dupped_search_request)
    boost_creators_and_title!(dupped_search_request)
    replace_umlauts!(dupped_search_request)

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
      ["query_string", "simple_query_string"].include?(_query.type)
    end
    .each do |_query|
      if _query.try(:default_field) == ["_all"] || _query.fields == ["_all"]
        _query.fields ||= []
        _query.fields.push("creator_contributor_search^2")
        _query.fields.push("title_search^4")
      end
    end
  end

  # This is somekind of a hack, in order to be able to use truncation (mütter*)
  # with words with umlauts. This modification assumes that umlauts are stored
  # as ae, oe, ue representation in the index.
  def replace_umlauts!(search_request)
    search_request.queries
    .select do |_query|
      ["query_string", "simple_query_string"].include?(_query.type)
    end
    .each do |_query|
      _query.query = _query.query
      .gsub("Ä", "Ae").gsub("ä", "ae")
      .gsub("Ö", "Oe").gsub("ö", "oe")
      .gsub("Ü", "Ue").gsub("ü", "ue")
      .gsub("ß", "ss")
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
