require "skala/record"
require_relative "../ubpb_elasticsearch_adapter"

class KatalogUbpb::UbpbElasticsearchAdapter::RecordFactory
  def self.call(source)
    Skala::Record.new(
      id: source["id"],
      hbz_id: source["ht_number"],
      signature: source["signature"],
      title: source["title_display"],
      creator: source["creator_contributor_display"],
      year_of_publication: source["creationdate"],
      created_at: source["cataloging_date"],
      edition: source["edition"],
      language: source["language"],
      publisher: source["publisher"],
      abstract: source["abstract"],
      note: source["additional_data"].try(:[], "local_comment"),
      description: source["description"],
      isbn: source["isbn"],
      issn: source["issn"],
      source: source["source"],
      content_type: source["inhaltstyp_facet"],
      media_type: source["erscheinungsform_facet"],
      carrier_type: source["materialtyp_facet"],
      format: source["format"],
      resource_link: map_urls(source["resource_link"]),
      toc_link: map_urls(source["link_to_toc"]),
      is_part_of: map_is_part_of(source["is_part_of"]),
      relation: map_relation(source["relation"]),
      subject: source["subject"],
      journal_holdings: source["ldsX"],
      journal_stock: source["journal_stock"],
      notation: source["notation"],
      is_superorder: source["is_superorder"],
      is_secondary_form: source["is_secondary_form"],

      secondary_form_year_of_publication: source["secondary_form_creationdate"],
      secondary_form_preliminary_phrase: source["secondary_form_preliminary_phrase"],
      secondary_form_isbn: source["secondary_form_isbn"],
      secondary_form_publisher: source["secondary_form_publisher"],
      secondary_form_physical_description: source["secondary_form_description"],
      secondary_form_is_part_of: map_is_part_of(source["secondary_form_superorder"])
    )
  end

  private

  def self.map_urls(value)
    [value].flatten(1).compact.map do |url|
      {
        url: url,
        label: nil
      }
    end
  end

  def self.map_is_part_of(value)
    [value].flatten(1).compact.map do |is_part_of|
      {
        superorder_id: is_part_of["ht_number"],
        label: is_part_of["label"],
        label_additions: is_part_of["label_additions"],
        volume_count: is_part_of["volume_count"]
      }
    end
  end

  def self.map_relation(value)
    [value].flatten(1).compact.map do |relation|
      {
        target_id: relation["ht_number"],
        label: relation["label"]
      }
    end
  end
end
