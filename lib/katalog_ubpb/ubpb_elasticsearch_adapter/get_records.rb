begin
  require "skala/elasticsearch_adapter/get_records"
rescue LoadError
  require "skala/adapter/get_records"
end

require_relative "../ubpb_elasticsearch_adapter"
require_relative "./record_factory"

class KatalogUbpb::UbpbElasticsearchAdapter::GetRecords < Skala::ElasticsearchAdapter::GetRecords
  # We implement get_records via search for the ubpb, so we can get records by their source id.
  # The original get needs the elasticsearch record id, which does not need to be the same.
  def call(record_ids)
    search_result = adapter.search({ queries: [{ type: "unscored_terms", field: "id", terms: record_ids }] })
    self.class::Result.new({records: search_result.hits}).tap do |_get_records_result|
      _get_records_result.source = search_result.source
      _get_records_result.each { |_element| _element.found = true }
    end
  end
end
