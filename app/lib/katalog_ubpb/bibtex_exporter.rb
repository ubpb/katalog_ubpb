class KatalogUbpb::BibtexExporter
  RECORD_TO_BIBTEX_MAPPING = {
    "creator"              => "author",
    "description"          => "note",
    "edition"              => "edition",
    "id"                   => "bibtex_key",
    "isbn"                 => "isbn",
    "is_part_of.label"     => "series",
    "issn"                 => "issn",
    "publisher"            => "publisher",
    "subject"              => "keywords",
    "title"                => "title",
    "year_of_publication"  => "year"
  }

  TYPE_MAPPINGS = {
    ["article"] => "article",
    ["book"] => "book",
    ["conference_proceeding"] => "inproceedings",
    ["dissertation"] => "phdthesis"
  }

  def self.call(record)
    bibtex_representation = {}

    RECORD_TO_BIBTEX_MAPPING.each do |_record_key, _bibtex_key|
      record_value = traverse(record, _record_key)
      .try do |_value|
        if _value.is_a?(Array)
          if _bibtex_key == "author"
            _value.join(" and ")
          else
            _value.join(", ")
          end
        else
          _value
        end
      end

      bibtex_representation[_bibtex_key] = record_value
    end

    record.try(:identifier).try(:find) { |element| element.type.to_s == "doi" }.try(:value).try do |doi|
      bibtex_representation["doi"] = doi
      bibtex_representation["url"] ||= "https://dx.doi.org/#{doi}"
    end

    if mapping = TYPE_MAPPINGS.find { |known_types, _| known_types.include?(record.content_type) }
      bibtex_representation["bibtex_type"] = mapping.last
    else
      bibtex_representation["bibtex_type"] = "misc"
    end

    case bibtex_representation["bibtex_type"]
    when "article" then bibtex_representation["journal"] = bibtex_representation.delete("series")
    when "inproceedings" then bibtex_representation["booktitle"] = bibtex_representation.delete("series")
    end

    if bibtex_representation.present?
      BibTeX::Entry.new(bibtex_representation.compact.symbolize_keys).to_s
    end
  end

  private

  # annahme das record und nur methoden accessor, kein hash, ist zulässig
  def self.traverse(object, path)
    if path.present?
      key = path.split(".").first
      remaining_path = path.split(".")[1..-1].presence.try(:join, ".")
    end

    if object.is_a?(Array)
      object.map { |_element| traverse(_element, path) }.presence
    elsif key.present? && object.respond_to?(key)
      traverse(object.send(key), remaining_path)
    elsif key.nil?
      object.presence
    end
  end
end
