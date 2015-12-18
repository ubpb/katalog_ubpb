class SearchRecordsService < Servizio::Service
  include InstrumentedService

  attr_accessor :adapter
  attr_accessor :facets
  attr_accessor :options
  attr_accessor :sanitize_search_request
  attr_accessor :search_request

  validates_presence_of :adapter
  validates_presence_of :search_request

  def facets?
    facets.present?
  end

  def sanitize_search_request
    [true, false].include?(@sanitize_search_request) ? @sanitize_search_request : true
  end

  def sanitize_search_request?
    sanitize_search_request == true
  end

  def call
    dupped_search_request = search_request.deep_dup
    add_facets!(dupped_search_request) if facets?
    sanitize!(dupped_search_request) if sanitize_search_request?

    result = adapter.search(dupped_search_request, options)

    # Order facets the way they have been configured/requested
    # Also filter facets that are not configured
    if result.facets.present?
      result.facets = @facets.each.inject([]) do |_ordered_facets, _requested_facet|
        _ordered_facets.push(
          result.facets.find{|_facet| _requested_facet["name"] == _facet.name}
        )
      end.tap(&:compact!)
    end

    result
  end

  private

  def add_facets!(search_request)
    search_request.tap do |_search_request|
      if _search_request.is_a?(Hash)
        _search_request.merge!(facets: facets)
      elsif _search_request.respond_to?(:facets=)
        _search_request.facets = facets
      end
    end
  end

  def escape(string, *characters)
    characters.inject(string) do |_string, _character|
      _string.gsub(_character, "\\#{_character}")
    end
  end

  def sanitize!(search_request)
    search_request.tap do |_search_request|
      characters_blacklist = "[", "]"
      sanitized_query_types = [:simple_query_string, :query_string]

      if _search_request.is_a?(Hash)
        _search_request[:queries].each do |_query|
          if sanitized_query_types.include?(_query[:type].to_sym)
            _query[:query] = escape(_query[:query], *characters_blacklist)
          end
        end
      elsif _search_request.respond_to?(:queries)
        _search_request.queries.each do |_query|
          if sanitized_query_types.include?(_query.type.to_sym)
            _query.query = escape(_query.query, *characters_blacklist)
          end
        end
      end
    end
  end
end
