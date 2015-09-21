require_relative "../get_record_items"

module KatalogUbpb
  class UbpbAlephAdapter::GetRecordItems::CorrectJournalSignatures
    def call!(record_item)
      source = WeakXml.new(record_item["_source"])

      if record_item["fields"]["signature"].try(:[], /\A\d+\w\d+\Z/)
        _collection_code = source.find("<z30-collection-code>").content
        record_item["fields"]["signature"].prepend("P#{_collection_code}/") if _collection_code.present?
      end
    end
  end
end
