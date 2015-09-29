module RecordsHelper::LinkToPredecessor
  def link_to_predecessor(record, search_request, scope, predecessors, successors, total_number_of_records, options = {}, &block)
    predecessor = Struct.new(:id, :scope, :search_request, :predecessors, :successors, :total_number_of_records).new(
      nil, scope, nil, nil, nil, total_number_of_records
    )

    if predecessors.present?
      predecessor.id = predecessors.last
      predecessor.predecessors = predecessors.slice(0..-2).presence
      predecessor.successors = (successors || []).dup.unshift(record.id)

      # search_request is the same as for record
      predecessor.search_request = search_request.deep_dup
    elsif search_request.from - search_request.size >= 0
      search_records = SearchRecords.new({
        search_engine_adapter: scope.search_engine_adapter,
        search_request: RecordsHelper::LinkToPredecessor.previous_page_search_request(search_request)
      })

      preceeding_record_ids = search_records.call.result[1].map(&:id)

      predecessor.id = preceeding_record_ids.last
      predecessor.predecessors = preceeding_record_ids.slice(0..-2)
      predecessor.successors = nil

      # search request is not the same as for record
      predecessor.search_request = search_records.search_request
    end

    predecessor.predecessors = predecessor.predecessors.to_json
    predecessor.successors = predecessor.successors.to_json

    link_to record_path(predecessor.to_h), options, &block if predecessor.id.present?
  end

  #
  # module methods
  #
  def self.previous_page_search_request(search_request)
    search_request.deep_dup.tap do |duplicated_search_request|
      duplicated_search_request.from = search_request.from - search_request.size
    end
  end
end
