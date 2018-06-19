require "skala/adapter/search"
require_relative "../primo_adapter"

class Skala::PrimoAdapter::GetRecords < Skala::Adapter::GetRecords
  def call(record_ids, options = {})
    # If you request more than 10 records via a search request (the limit seems
    # to be around 14) primo responds with a "search.error.illegal.search.term".
    # In order to circumvent this, one has to split things up into requests not
    # more than 10 records.

    search_results =
    [record_ids].flatten(1).each_slice(10).map do |_record_ids|
      search_request = Skala::Adapter::Search::Request.new(
        queries: [
          {
            type: "ids",
            query: _record_ids
          }
        ]
      )

      adapter.search(search_request, on_campus: true) # because you know the id -> you searched before
    end

    hits = search_results.map(&:hits).flatten(1)
    sources = search_results.map(&:source).flatten(1) # somekind of real merge would be cooler, but is more complicated

    self.class::Result.new(records: hits).tap do |_get_records_result|
      _get_records_result.source = sources
      _get_records_result.each do |_element|
        _element.found = true
        _element.version = 1
      end

      # add "pseudo" records if the given record id was not found
      record_ids.each do |_record_id|
        if _get_records_result.none? { |_element| _element.record.id == _record_id }
          _get_records_result.records << _get_records_result.class::Record.new(record: { id: _record_id })
        end
      end
    end
  end
end
