class SearchRecordsService < Servizio::Service
  attr_accessor :adapter
  attr_accessor :facets
  attr_accessor :search_request

  validates_presence_of :adapter
  validates_presence_of :search_request

  def call
    result = search_request.deep_dup.try do |_search_request|
      _search_request.facets = facets
      adapter.search_records(_search_request)
    end

    # Order facets the way they have been configured/requested
    # Also filter facets that are not configured
    if result.facets
      result.facets = @facets.each.inject([]) do |_ordered_facets, _requested_facet|
        _ordered_facets.push(
          result.facets.find{|_facet| _requested_facet["name"] == _facet.name}
        )
      end.tap(&:compact!)
    end

    # Inject i18n_key in term facets as defined in config
    if result.facets
      result.facets.each do |_facet|
        if _facet.is_a?(Skala::SearchResult::TermsFacet)
          _facet.i18n_key = @facets.find{|_requested_facet| _requested_facet["name"] == _facet.name}.try(:[], "i18n_key")
        end
      end
    end

    result
  end
end
