require_relative "../request"
require_relative "./query"

class Skala::Adapter::Search::Request::MatchQuery < Skala::Adapter::Search::Request::Query
  attribute :field, String, required: true
  attribute :query, String, required: true
end
