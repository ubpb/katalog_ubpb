require_relative "../ubpb_aleph_adapter"

class KatalogUbpb::UbpbAlephAdapter::Item < Skala::AlephAdapter.item_class
  include Virtus.model

  attribute :signature
  attribute :must_be_ordered_from_closed_stack, Virtus::Attribute::Boolean, default: false
end
