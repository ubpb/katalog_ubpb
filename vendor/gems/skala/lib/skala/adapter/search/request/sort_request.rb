require_relative "../request"

class Skala::Adapter::Search::Request::SortRequest
  include Virtus.model

  class Order < Virtus::Attribute
    def coerce(value)
      value = value.try(:to_s).try(:downcase)
      ["asc", "desc"].include?(value) ? value : nil
    end
  end

  attribute :field, String, required: true
  attribute :order, Order,  lazy: true
end
