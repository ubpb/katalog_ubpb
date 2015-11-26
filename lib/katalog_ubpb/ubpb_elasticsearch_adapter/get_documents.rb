require "skala/elasticsearch_adapter/get_documents"
require_relative "../ubpb_elasticsearch_adapter"
require_relative "../record_mapper"

class KatalogUbpb::UbpbElasticsearchAdapter::GetDocuments < Skala::ElasticsearchAdapter::GetDocuments

  def call(options = {})
    result = super(options)
    map_records!(result)
    result
  end

private

  def map_records!(result)
    mapper = KatalogUbpb::RecordMapper.new

    result.documents.map! do |_doc|
      doc = result.source["docs"].find{|d| d["_id"] == _doc.id}

      if doc
        _doc.record = mapper.map_record(doc["_source"])
      end

      _doc
    end
  end

end
