require_relative "../request"
require_relative "./query"

class Skala::Adapter::Search::Request::IdsQuery < Skala::Adapter::Search::Request::Query
  attribute :query, Array[BasicObject], required: true
end
