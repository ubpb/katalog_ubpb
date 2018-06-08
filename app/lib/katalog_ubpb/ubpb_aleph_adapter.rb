require "skala/aleph_adapter"
require "virtus"

module KatalogUbpb
  class UbpbAlephAdapter < Skala::AlephAdapter
    require_relative "ubpb_aleph_adapter/get_record_items"
    require_relative "ubpb_aleph_adapter/authenticate_user"
  end
end
