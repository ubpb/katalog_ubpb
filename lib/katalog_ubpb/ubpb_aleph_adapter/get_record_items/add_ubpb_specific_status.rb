require_relative "../get_record_items"

module KatalogUbpb
  class UbpbAlephAdapter::GetRecordItems::AddUbpbSpecificStatus
    def call!(record_item)
      source = WeakXml.new(record_item["_source"])

      record_item["fields"]["status"] ||=
      case source.find("<status>").content
        when /Storniert/      then "cancelled"
        when /Reklamiert/     then "complained"
        when /Erwartet/       then "expected"
        when /In Bearbeitung/ then "in_process"
        when /Verlust/        then "lost"
        when /Vermisst/       then "missing"
        when /Bestellt/       then "on_order"
      end
    end
  end
end
