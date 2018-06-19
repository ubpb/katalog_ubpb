require_relative "../request"
require_relative "./query"

class Skala::Adapter::Search::Request::RangeQuery < Skala::Adapter::Search::Request::Query
  attribute :field, String,      required: true
  attribute :gte,   BasicObject, lazy: true
  attribute :lte,   BasicObject, lazy: true
end
