require_relative "../ubpb_aleph_adapter"

module KatalogUbpb
  class UbpbAlephAdapter::GetRecordItems
    require_relative "get_record_items/add_availability"
    require_relative "get_record_items/add_ubpb_specific_status"
    require_relative "get_record_items/correct_journal_signatures"
    require_relative "get_record_items/extend_description"

    def initialize(adapter)
      @adapter = adapter
    end

    def call(record_id)
      record_id
      .try do |_record_id|
        record_id.gsub("PAD_ALEPH", "").prepend(@adapter.aleph_adapter.default_document_base)
      end
      .try do |_sanitized_record_id|
        @adapter.aleph_adapter.get_record_items(_sanitized_record_id)
      end
      .tap do |_aleph_adapter_result|
        _aleph_adapter_result["hits"]["hits"].each do |_hit|
          AddAvailability.new.call!(_hit)
          AddUbpbSpecificStatus.new.call!(_hit)
          CorrectJournalSignatures.new.call!(_hit)
          ExtendDescription.new(@adapter.aleph_adapter.x_services_url).call!(_hit)
        end
      end
    end
  end
end
