class SearchRecordsService < Servizio::Service
  include InstrumentedService

  attr_accessor :adapter
  attr_accessor :facets
  attr_accessor :search_request

  validates_presence_of :adapter
  validates_presence_of :search_request

  def faceted_search_request
    if facets
      if search_request.is_a?(Hash)
        search_request.deep_dup.merge(facets)
      elsif search_request.respond_to?(:facets=)
        search_request.deep_dup.tap do |_dupped_search_request|
          _dupped_search_request.facets = facets
        end
      end
    else
      search_request
    end
  end

  def call
    result = adapter.search(faceted_search_request)

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
end
