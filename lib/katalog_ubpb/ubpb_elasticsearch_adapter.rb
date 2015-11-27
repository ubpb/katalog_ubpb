require "skala/elasticsearch_adapter"

module KatalogUbpb
  class UbpbElasticsearchAdapter < Skala::ElasticsearchAdapter
    require_relative "ubpb_elasticsearch_adapter/search"
    require_relative "ubpb_elasticsearch_adapter/get_documents"
  end
end
