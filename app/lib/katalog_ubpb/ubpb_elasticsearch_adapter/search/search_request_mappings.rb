require_relative "../search"

module KatalogUbpb::UbpbElasticsearchAdapter::Search::SearchRequestMappings
  require_relative "./search_request_mappings/query_mapping"
  require_relative "./search_request_mappings/sort_request_mapping"

  @@mappings = [
    QueryMapping.new("cdate" => "creationdate_search"),
    QueryMapping.new("creationdate" => "creationdate_facet") do |_query, _search_request|
      if original_facet_query = _search_request.facet_queries.find { |_facet_query| _facet_query == _query }
        field = original_facet_query.field
        gte, lte = original_facet_query.query.gsub(/\[|\]|\s/, "").split("TO")
        new_facet_query = Skala::Adapter::Search::Request::RangeQuery.new(field: field, gte: gte, lte: lte)

        _search_request.facet_queries =
        _search_request.facet_queries
        .reject { |_facet_query| _facet_query == original_facet_query }
        .push(new_facet_query)
      end
    end,
    QueryMapping.new("creator" => "creator_contributor_search"),
    QueryMapping.new("isbn" => "isbn_search"),
    QueryMapping.new("lang" => "language_facet"),
    QueryMapping.new("lsr05" => "ht_number"),
    QueryMapping.new("lsr10" => "signature_search"),
    QueryMapping.new("lsr15" => "notation"),
    QueryMapping.new("lsr34" => "publisher"),
    QueryMapping.new("sub" => "subject_search"),
    QueryMapping.new("title" => "title_search"),
    QueryMapping.new("tlevel" => "materialtyp_facet") do |_query|
      if _query.try(:query) == "online_resources"
        _query.query = "online_resource"
      end
    end,
    SortRequestMapping.new("lso02" => "volume_count_sort2"),
    SortRequestMapping.new("lso03" => "notation_sort"),
    SortRequestMapping.new("lso48" => "cataloging_date") do |_sort_request|
      _sort_request.order = "desc"
    end,
    SortRequestMapping.new("lso49" => "volume_count_sort2") do |_sort_request|
      _sort_request.order = "asc"
    end,
    SortRequestMapping.new("lso50" => "volume_count_sort2") do |_sort_request|
      _sort_request.order = "desc"
    end,
    SortRequestMapping.new("rank" => "_score"),
    SortRequestMapping.new("scdate" => "creationdate_facet") do |_sort_request|
      _sort_request.order = "desc"
    end,
    SortRequestMapping.new("screator" => "creator_contributor_facet"),
    SortRequestMapping.new("stitle" => "title_sort")
  ]

  def self.each
    return @@mappings.each unless block_given?

    @@mappings.each do |_mapping|
      yield _mapping
    end
  end
end
