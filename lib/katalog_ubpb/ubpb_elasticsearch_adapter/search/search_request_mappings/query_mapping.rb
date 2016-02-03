require_relative "../search_request_mappings"
require_relative "./mapping"

class KatalogUbpb::UbpbElasticsearchAdapter::Search::SearchRequestMappings::QueryMapping < KatalogUbpb::UbpbElasticsearchAdapter::Search::SearchRequestMappings::Mapping
  def call!(object, search_request = nil)
    super if object.class <= Skala::Adapter::Search::Request::Query
  end
end
