require_relative "../request"
require_relative "./query"

class Skala::Adapter::Search::Request::SimpleQueryStringQuery < Skala::Adapter::Search::Request::Query
  attribute :default_operator, String,        default: "AND"
  attribute :fields,           Array[String], required: true
  attribute :query,            String,        required: true
end
