class KatalogUbpb::PermalinkTranslator
  def self.recognizes?(params)
    params.keys.include?("q") || params.keys.include?("query_terms")
  end

  def self.translate(params)
    {
      scope: scope(params),
      search_request: search_request(params).to_json
    }
  end

  def self.scope(params)
    case params["scope"]
    when "primo_central" then "primo_central"
    else "local"
    end
  end

  def self.search_request(params)
    {
      # facet_queries: facet_queries(params),
      queries: queries(params),
    }
    .compact
  end

=begin
  def self.facet_queries(params)
    if old_facet_queries = params["f"]
      old_facet_queries.map do |_key, _value|
        [_value].flatten(1).compact.map do |__value|
          {
            type: "match",
            field: index_field_mapping(_key),
            query: __value 
          }
        end
      end.flatten
    end
  end
=end

  def self.index_field_mapping(index_field)
    case index_field
    when "creator" then "creator_contributor_search"
    when "title"   then "title_search"
    when "sub"     then "subject_search"
    when "lsr34"   then "publisher"
    when "toc"     then "toc"
    when "cdate"   then "creationdate_search"
    when "isbn"    then "isbn_search"
    when "issn"    then "issn"
    when "lsr10"   then "signature_search"
    when "lsr15"   then "notation"
    when "lsr05"   then "ht_number"
    when "tlevel"  then "materialtyp_facet"
    else index_field
    end
  end

  def self.queries(params)
    (params["query_terms"] || [params]).map do |_query_term|
      if _query_term["po"] == "exact"
        {
          type: "match",
          field: _query_term["if"],
          query: _query_term["q"]
        }.compact
      else
        {
          type: "query_string",
          fields: if (index_field = _query_term["if"]) != "any" # we should not leave any in place, it should use default per scope
            [index_field_mapping(index_field)].compact.presence
          end,
          query: _query_term["q"]
        }.compact
      end
      .compact
    end
  end
end
