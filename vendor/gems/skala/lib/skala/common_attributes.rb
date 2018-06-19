require_relative "../skala"

module Skala::CommonAttributes
  include Virtus.model

  attribute :ils_record_id
  attribute :search_engine_record_id

  attribute :contributor
  attribute :created
  attribute :creator
  attribute :creation_date
  attribute :edition
  attribute :language
  attribute :place_of_publication
  attribute :publisher
  attribute :signature
  attribute :title
end
