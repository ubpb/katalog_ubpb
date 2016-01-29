require "skala/elasticsearch_adapter/search"
require_relative "../ubpb_elasticsearch_adapter"
require_relative "./record_factory"
require_relative "./search/index_field_mappings"

class KatalogUbpb::UbpbElasticsearchAdapter::Search < Skala::ElasticsearchAdapter::Search
  def call(search_request, options = {})
    # modifiy the given search_request
    map_index_fields!(search_request)

    # work an a copy from here
    dupped_search_request = search_request.deep_dup
    add_query_to_ignore_deleted_records!(dupped_search_request)
    boost_creators_and_title!(dupped_search_request)
    replace_umlauts!(dupped_search_request)

    # _primary_first is used to avoid "jumping" (different) search result for the same search request
    # For other options see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-preference.html
    search_result = super(dupped_search_request, preference: "_primary_first")

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

  def map_index_fields!(search_request)
    if defined?(INDEX_FIELD_MAPPINGS)
      lookup_field_value = -> (mapping, field_name, field_value = nil) do
        mapped_field_name = mapping[field_name.to_s] || mapping[field_name.to_sym] || field_name
        values_mapping = mapped_field_name.values.first if mapped_field_name.is_a?(Hash)

        if values_mapping.is_a?(String)
          values_mapping
        elsif values_mapping.is_a?(Hash)
          values_mapping[field_value] || field_value
        else
          field_value
        end
        .tap do |_mapped_field_value|
          if field_value != _mapped_field_value
            search_request.changed = true
          end
        end
      end

      lookup_index_field = -> (mapping, field_name) do
        mapped_field_name = mapping[field_name.to_s] || mapping[field_name.to_sym] || field_name

        if mapped_field_name.is_a?(Hash)
          mapped_field_name.keys.first
        else
          mapped_field_name
        end
        .tap do |_mapped_field_name|
          if field_name != _mapped_field_name
            search_request.changed = true
          end
        end
      end

      (INDEX_FIELD_MAPPINGS.try(:compact).presence || []).each do |_index_field_mapping|
        [search_request.facets, search_request.queries, search_request.facet_queries].flatten(1).compact.each do |_object|
          if _object.respond_to?(:field)
            original_field = _object.field
            _object.field = lookup_index_field.call(_index_field_mapping, original_field)

            if _object.respond_to?(:query=)
              original_query = _object.query
              _object.query = lookup_field_value.call(_index_field_mapping, original_field, original_query)
            end
          elsif _object.respond_to?(:fields)
            _object.fields = _object.fields.try(:map) do |_field|
              lookup_index_field.call(_index_field_mapping, _field)
            end
          end
        end

        search_request.sort.try(:each) do |_sort_request|
          original_field = _sort_request.field
          _sort_request.field = lookup_index_field.call(_index_field_mapping, original_field)

          if order = lookup_field_value.call(_index_field_mapping, original_field)
            _sort_request.order = order
          end
        end
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
