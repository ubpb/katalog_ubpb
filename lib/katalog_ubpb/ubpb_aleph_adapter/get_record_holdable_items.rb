require "skala/aleph_adapter/get_record_holdable_items"
require_relative "../ubpb_aleph_adapter"

class KatalogUbpb::UbpbAlephAdapter::GetRecordHoldableItems < Skala::AlephAdapter::GetRecordHoldableItems
  def call(document_number, username, options = {})
    super.tap do |_aleph_adapter_result|
      _aleph_adapter_result.holdable_items.reject! do |_holdable_item|
        ["Seminarapparat", "Tischapparat", "Handapparat"].include?(_holdable_item.item_status)
      end
    end
  end
end
