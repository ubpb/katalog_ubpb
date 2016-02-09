class SearchRecordsService < Servizio::Service
  include InstrumentedService

  attr_accessor :adapter
  attr_accessor :facets
  attr_accessor :options
  attr_accessor :search_request

  validates_presence_of :adapter
  validates_presence_of :search_request

  def facets?
    facets.present?
  end

  def call
    add_facets!(search_request) if facets?
    result = adapter.search(search_request, options)
    remove_facets!(search_request) if facets?

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

  def remove_facets!(search_request)
    search_request.tap do |_search_request|
      if _search_request.is_a?(Hash)
        _search_request.delete(:facets)
        _search_request.delete("facets")
      elsif _search_request.respond_to?(:facets=)
        _search_request.facets = nil
      end
    end
  end
end
