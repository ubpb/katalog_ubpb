module RecordsHelper::LinkToSuccessor
  def link_to_successor(record, search_request, scope, predecessors, successors, total_number_of_records, options = {}, &block)
    successor = Struct.new(:id, :scope, :search_request, :predecessors, :successors, :total_number_of_records).new(
      nil, scope, nil, nil, nil, total_number_of_records
    )

    if successors.present?
      successor.id = successors.first
      successor.predecessors = (predecessors || []).dup.push(record.id)
      successor.successors = successors.slice(1..-1)

      # search_request is the same as for record
      successor.search_request = search_request.deep_dup
    elsif search_request.from + search_request.size < total_number_of_records
      search_records = SearchRecords.new({
        search_engine_adapter: scope.search_engine_adapter,
        search_request: RecordsHelper::LinkToSuccessor.next_page_search_request(search_request)
      })

      succeeding_record_ids = search_records.call.result[1].map(&:id)

      successor.id = succeeding_record_ids.first
      successor.predecessors = nil
      successor.successors = succeeding_record_ids.slice(1..-1)

      # search request is not the same as for record
      successor.search_request = search_records.search_request
    end

    successor.predecessors = successor.predecessors.to_json
    successor.successors = successor.successors.to_json

    link_to record_path(successor.to_h), options, &block if successor.id.present?
  end

  #
  # module methods
  #
  def self.next_page_search_request(search_request)
    search_request.deep_dup.tap do |duplicated_search_request|
      duplicated_search_request.from = search_request.from + search_request.size
    end
  end
end
