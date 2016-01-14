module RecordFieldsHelper

  def ht_number(record)
    record.hbz_id
  end

  def title(record, scope:nil, search_request:nil)
    if record.try(:title)
      sanitized_title = HTMLEntities.new.decode(record.title)

      if record.id && scope
        link_to(sanitized_title, record_path(record.id, scope: scope, search_request: search_request)).html_safe
      else
        sanitized_title
      end
    end
  end

  def creators(record, link:false, scope:nil)
    if record.try(:creator)
      record.creator.map do |creator|
        if link && scope && creator != "[u.a.]"
          link_to_creator(creator, scope: scope)
        else
          creator
        end
      end.join("; ").html_safe
    end
  end

  def edition(record)
    record.try(:edition)
  end

  def date_of_publication(record)
    record.try(:year_of_publication)
  end

  def publisher(record)
    record.publisher.join(", ")
  end

  def signature(record, link: false)
    if signature = record.try(:signature)
      if link
        link_to(signature, go_signature_path, target: "_blank").html_safe
      else
        signature
      end
    end
  end

  def format(record)
    record.format
  end

  def language(record)
    record.language.map { |_language| t("languages.#{_language}", default: _language) }.join(", ")
  end

  def description(record)
    record.description.map{|d| HTMLEntities.new.encode(d)}.join("<br/>").html_safe
  end

  def note(record)
    record.note.map{|d| HTMLEntities.new.encode(d)}.join("<br/>").html_safe
  end

  def identifier(record)
    identifiers = []

    # ISBNS
    identifiers += record.isbn.map{|isbn| "ISBN: #{isbn}"}
    # ISSNS
    identifiers += record.issn.map{|issn| "ISSN: #{issn}"}
    # other identifiers
    identifiers += record.identifier.map{|i| "#{i.type.upcase}: #{i.value}"}

    if identifiers.present?
      identifiers.join("<br/>").html_safe
    end
  end

  def notations(record, link:false, scope:nil)
    record.notation.map do |notation|
      if link && scope
        link_to_notation(notation, scope: scope)
      else
        notation
      end
    end.join(", ").html_safe
  end

  def relations(record, link:false, scope:nil)
    relations = record.relation

    if relations.present?
      content_tag(:ul) do
        relations.map do |relation|
          target_id = relation["target_id"]
          label     = relation["label"] || "n.a."

          content_tag(:li) do
            if link && scope && target_id
              link_to_ht_number(target_id, scope: scope, label: label)
            else
              label
            end
          end
        end.join.html_safe
      end
    end
  end

  def subject(record, link:false, scope:nil)
    subjects = record.subject

    subjects.map do |subject|
      if link && scope
        link_to_subject(subject, scope: scope)
      else
        subject
      end
    end.join(", ").html_safe
  end

  def source(record)
    record.source
  end

  def links_to_toc(record, print_mode: false)
    record.toc_link.map.with_index do |link, index|
      if print_mode
        link_to link.url
      else
        label = index == 0 ? "Inhaltsverzeichnis anzeigen" : "Weiteres Inhaltsverzeichnis anzeigen"
        link_to label, link.url, target: "_blank"
      end
    end.join("<br/>").html_safe
  end

  def is_part_of(record, prefix_label:nil, scope:nil)
    if (superorders = record.try(:is_part_of)).present?
      content_tag(:ul) do
        superorders.map do |superorder|
          content_tag(:li) do
            superorder_entry(superorder, prefix_label: prefix_label, scope: scope)
          end
        end.join.html_safe
      end
    end
  end

  def snd_date_of_publication(record)
    record.secondary_form_year_of_publication
  end

  def snd_preliminary_phrase(record)
    record.secondary_form_preliminary_phrase
  end

  def snd_isbn(record)
    record.isbn.join(", ")
  end

  def snd_publisher(record)
    record.secondary_form_publisher.join(", ")
  end

  def snd_physical_description(record)
    record.secondary_form_physical_description
  end

  def snd_is_part_of(record, prefix_label:nil, scope:nil)
    if (superorders = record.secondary_form_is_part_of).present?
      content_tag(:ul) do
        superorders.map do |superorder|
          content_tag(:li) do
            superorder_entry(superorder, prefix_label: prefix_label, scope: scope)
          end
        end.join.html_safe
      end
    end
  end

private

  def superorder_entry(superorder, prefix_label:nil, scope:nil)
    buffer = "#{prefix_label}"

    label  = superorder["label"]
    label << ": #{[*superorder["label_additions"]].join(", ")}" if superorder["label_additions"].present?
    label << "; #{superorder["volume_count"]}" if superorder["volume_count"].present?
    superorder["label"] = label

    if scope.present? && superorder["superorder_id"].present?
      buffer << " #{link_to_superorder(superorder["superorder_id"], scope: scope, label: superorder["label"])}"
    else
      buffer << " #{superorder["label"]}"
    end

    if scope.present? && superorder["superorder_id"].present?
      buffer << " #{link_to_volumes(superorder["superorder_id"], scope: scope, label: "(alle Bände)")}"
    end

    buffer.html_safe
  end

end
