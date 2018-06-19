require_relative "../request"
require_relative "./query"

class Skala::Adapter::Search::Request::QueryStringQuery < Skala::Adapter::Search::Request::Query
  attribute :default_field,    String, lazy: true
  attribute :default_operator, String, default: "AND"
  attribute :fields,           Array[String], laze: true
  attribute :query,            String, required: true
end
