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
      facet_queries: facet_queries(params),
      queries: queries(params),
      sort: sort(params)
    }
    .compact
  end

  def self.facet_queries(params)
    if old_facet_queries = params["f"]
      old_facet_queries.map do |_key, _value|
        [_value].flatten(1).compact.map do |__value|
          {
            type: "match",
            field: _key,
            query: __value 
          }
        end
      end.flatten
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
          fields: if (index_field = _query_term["if"]) != "any" # we should not leave "any" in place, it should use scope default
            [index_field].compact.presence
          end,
          query: _query_term["q"]
        }.compact
      end
      .compact
    end
  end

  def self.sort(params)
    if params["sf"]
      [
        {
          field: params["sf"] 
        }
      ]
    end
  end
end
