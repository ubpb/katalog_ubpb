class KatalogUbpb::UbpbElasticsearchAdapter::Search::SearchRequestMappings::SortRequestMapping < KatalogUbpb::UbpbElasticsearchAdapter::Search::SearchRequestMappings::Mapping
  def call!(object, search_request = nil)
    super if object.class <= Skala::Adapter::Search::Request::SortRequest
  end
end
