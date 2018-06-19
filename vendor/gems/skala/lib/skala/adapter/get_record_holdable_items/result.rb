require "skala/adapter/operation/result"
require "skala/item"
require_relative "../get_record_holdable_items"

class Skala::Adapter::GetRecordHoldableItems::Result < Skala::Adapter::Operation::Result
  include Enumerable
  include Virtus.model

  attribute :holdable_items, Array[Skala::Item]

  def each
    block_given? ? holdable_items.each { |_element| yield _element } : holdable_items.each
  end
end
