module RecordRelatedService
  extend ActiveSupport::Concern

  # A helper method which tries to update the record property of each element
  # of a collection of objects responding to 'record'. Therefor, it issues a
  # search using the given search_engine_adapter and updates the record property
  # for each element where a corresponding search result hit is present.
  #
  # @example
  #   get_record_items_result = ils_adapter.get_record_items(record_id)
  #   update_records!(get_record_items_result)
  #
  def update_records!(collection, search_engine_adapter)
    if collection.any? && search_engine_adapter
      record_ids = collection.map(&:record).map(&:id).compact

      if record_ids.any?
        search_result = SearchRecordsService.call(
          adapter: search_engine_adapter,
          search_request: {
            queries: [
              {
                # TODO: no need for ordered_terms here, use something like 'unscored_terms'
                type: "ordered_terms",
                field: "id",
                terms: record_ids
              }
            ],
            # count is used instead of length, because collection is an Enumerable, not an array
            size: record_ids.count
          }
        )

        collection.each do |_element|
          if corresponding_hit = search_result.find { |_hit| _hit.record.id == _element.record.id }
            _element.record = corresponding_hit.record
          end
        end
      end
    end

    return collection
  end

end
