require "skala/adapter/operation/result"
require "skala/item"
require_relative "../get_record_items"

class Skala::Adapter::GetRecordItems::Result < Skala::Adapter::Operation::Result
  include Enumerable
  include Virtus.model

  attribute :items, Array[Skala::Item]

  def each
    block_given? ? items.each { |_element| yield _element } : items.each
  end
end
