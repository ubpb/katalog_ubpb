module AdapterRelatedService
  extend ActiveSupport::Concern

  # A helper method which tries to remvoe the source from a an adapter result.
  # Not having the source around simplifies working with the results, e.g. in
  # pry. At this point, the source should not be needed anyway. 
  #
  # @example
  #   get_record_items_result = ils_adapter.get_record_items(record_id)
  #   strip_source!(get_record_items_result)
  #
  def strip_source!(adapter_result)
    if adapter_result.respond_to?(:source=)
      adapter_result.source = nil
    end

    return adapter_result
  end

end
