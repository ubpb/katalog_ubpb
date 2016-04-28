require "skala/aleph_adapter"
require "virtus"

module KatalogUbpb
  class UbpbAlephAdapter < Skala::AlephAdapter
    require_relative "ubpb_aleph_adapter/get_record_items"

    LOCATION_LOOKUP_TABLE ||= begin
      location_lookup_table_filename = File.join(File.dirname(__FILE__), "ubpb_aleph_adapter", "location_lookup_table.yml")

      if File.exist?(location_lookup_table_filename)
        YAML.load_file(location_lookup_table_filename)
      else
        []
      end
    end
  end
end
