require "skala/elasticsearch_adapter"

module KatalogUbpb
  class UbpbElasticsearchAdapter < Skala::ElasticsearchAdapter
    require_relative "ubpb_elasticsearch_adapter/search_records"
  end
end
