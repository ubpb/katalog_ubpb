require_relative "../request"
require_relative "./query"

class Skala::Adapter::Search::Request::UnscoredTermsQuery < Skala::Adapter::Search::Request::Query
  attribute :field, String,             required: true
  attribute :terms, Array[BasicObject], required: true
end
