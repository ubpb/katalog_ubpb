require "skala/elasticsearch_adapter/get_documents"
require_relative "../ubpb_elasticsearch_adapter"
require_relative "./record_factory"

class KatalogUbpb::UbpbElasticsearchAdapter::GetDocuments < Skala::ElasticsearchAdapter::GetDocuments

  def call(options = {})
    result = super(options)
    map_records!(result)
    result
  end

private

  def map_records!(result)
    result.documents.map! do |_result_document|
      _result_doc.tap do |_result_doc|
        if source_doc = result.source["docs"].find{ |_source_doc| _source_doc["_id"] == _result_doc.id }
          _result_doc.record = self.class.parent::RecordFactory.call(source_doc["_source"])
        end
      end
    end
  end

end
