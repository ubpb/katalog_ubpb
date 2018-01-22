class KatalogUbpb::Item < Skala::Item

  attribute :signature, String
  attribute :must_be_ordered_from_closed_stack, Boolean, default: false
  attribute :collection_code, String

end
