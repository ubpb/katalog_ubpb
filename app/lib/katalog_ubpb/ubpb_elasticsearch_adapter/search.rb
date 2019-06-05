require "skala/elasticsearch_adapter/search"
require_relative "../ubpb_elasticsearch_adapter"
require_relative "./record_factory"
require_relative "./search/search_request_mappings"

class KatalogUbpb::UbpbElasticsearchAdapter::Search < Skala::ElasticsearchAdapter::Search
  def call(search_request, options = {})
    # modifiy the given search_request
    map_index_fields!(search_request)

    # work an a copy from here
    dupped_search_request = search_request.deep_dup
    filter_nil_queries!(dupped_search_request)
    add_query_to_ignore_deleted_records!(dupped_search_request)
    boost_creators_and_title!(dupped_search_request)
    escape_special_characters!(dupped_search_request)
    replace_operators!(dupped_search_request)
    replace_umlauts!(dupped_search_request)

    # _primary_first is used to avoid "jumping" (different) search result for the same search request
    # For other options see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-preference.html
    search_result = super(dupped_search_request, preference: "_primary_first")

    set_hits!(search_result)
    search_result
  end

  private # search request transformation

  def filter_nil_queries!(search_request)
    search_request.queries = search_request.queries.select do |query|
      if ["query_string", "simple_query_string"].include?(query.type)
        query.query != nil
      else
        true
      end
    end
  end

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
      if _query.try(:default_field) == ["custom_all"] || _query.fields.try(:include?, "custom_all")
        _query.fields ||= []
        _query.fields.push("creator_contributor_search^2")
        _query.fields.push("title_search^4")
      end
    end
  end

  def escape_special_characters!(search_request)
    escape = -> (string, *characters) do
      characters.inject(string) do |_string, _character|
        # adapted from http://stackoverflow.com/questions/7074337/why-does-stringgsub-double-content
        _string.gsub(_character) { |_match| "\\#{_match}" } # avoid regular expression replacement string issues
      end
    end

    # \ has to be escaped be itself AND has to be the first, to
    # avoid double escaping of other escape sequences
    characters_blacklist = %w(\\ + - = && || > < ! { } [ ] ^ : /)
    sanitized_query_types = [:simple_query_string, :query_string]

    search_request.queries.each do |_query|
      if sanitized_query_types.include?(_query.type.to_sym)
        _query.query = escape.call(_query.query, *characters_blacklist)
      end
    end
  end

  def map_index_fields!(search_request)
    [
      search_request.facets,
      search_request.queries,
      search_request.facet_queries,
      search_request.sort
    ]
    .flatten(1)
    .compact
    .each do |_search_request_object|
      SearchRequestMappings.each do |_mapping|
        _mapping.call!(_search_request_object, search_request)
      end
    end
  end

  def replace_operators!(search_request)
    search_request.queries
    .select do |_query|
      ["query_string", "simple_query_string"].include?(_query.type)
    end
    .each do |_query|
      _query.query = _query.query
      .gsub("UND", "AND")
      .gsub("ODER", "OR")
      .gsub("NICHT", "NOT")
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
        _hit.record = self.class.module_parent::RecordFactory.call(source_hit["_source"])
      end
    end
  end
end
