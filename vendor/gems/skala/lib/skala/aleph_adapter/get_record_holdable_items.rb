require "nokogiri"
require "skala/adapter/get_record_holdable_items"
require_relative "../aleph_adapter"
require_relative "./get_record_items"

class Skala::AlephAdapter::GetRecordHoldableItems < Skala::Adapter::GetRecordHoldableItems
  def call(document_number, username, options = {})
    get_record_items_result = get_record_items(document_number, options.merge(username: username))

    self.class::Result.new(
      holdable_items: holdable_items(get_record_items_result),
      source: get_record_items_result.source
    )
  end

  private

  def get_record_items(*args)
    adapter.class::GetRecordItems.new(adapter).call(*args) # adapter.class is important to get inherited op
  end

  def holdable_items(get_record_items_result)
    source_doc = Nokogiri::XML(get_record_items_result.source)

    get_record_items_result.items.select do |_item|
      _item.hold_request_can_be_created == true
    end
  end
end
