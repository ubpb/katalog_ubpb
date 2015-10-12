require "skala/elasticsearch_adapter/search_records"
require_relative "../ubpb_elasticsearch_adapter"

class KatalogUbpb::UbpbElasticsearchAdapter::SearchRecords < Skala::ElasticsearchAdapter::SearchRecords
  def call(search_request)
    search_request = search_request.deep_dup
    add_query_to_ignore_deleted_records!(search_request)
   
    result = super(search_request)
    
    result.hits.each do |_hit|
      rename_superorder_display_to_is_part_of!(_hit)
      replace_title_with_short_title_display!(_hit)

      # must be the last one
      sort_fields!(_hit)
    end

    result
  end

  private # search request transformation

  def add_query_to_ignore_deleted_records!(search_request)
    search_request.queries << Skala::SearchRequest::MatchQuery.new(query: "A", field: "status")
  end

  private # seach result transformation

  def rename_superorder_display_to_is_part_of!(hit)
    if hit.fields["superorder_display"].present?
      hit.fields["is_part_of"] = hit.fields.delete("superorder_display")
    end
  end

  def replace_title_with_short_title_display!(hit)
    hit.fields["title"] = hit.fields.delete("short_title_display")
  end

  def sort_fields!(hit)
    hit.fields = hit.fields.sort.to_h
  end
end
