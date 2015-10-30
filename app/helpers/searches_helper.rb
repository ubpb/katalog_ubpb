module SearchesHelper

  def link_to_previous_page(scope, search_request)
    from = search_request.from - search_request.size
    enabled = search_request.from > 0

    if enabled
      link_to_page(scope, search_request, from) do
        fa_icon("angle-left")
      end
    end
  end

  def link_to_next_page(scope, search_request, total_records)
    from = search_request.from + search_request.size
    enabled = from < total_records

    if enabled
      link_to_page(scope, search_request, from) do
        fa_icon("angle-right")
      end
    end
  end

  def page_stats(scope, search_request, total_records)
    page_start = search_request.from + 1
    page_end   = search_request.from + search_request.size
    page_end   = total_records if page_end > total_records

    link_to_page(scope, search_request, 0) do
      content_tag :span, class: "page-stats" do
        "#{page_start} – #{page_end} von #{total_records}"
      end
    end
  end

  def link_to_page(scope, search_request, from)
    link_to searches_path(
      search_request: search_request.deep_dup.tap do |_search_request|
        _search_request.from = from
      end,
      scope: scope
    ),
    class: "btn btn-default" do
      yield
    end
  end


  #
  # ------
  #


  def link_to_superorder(ht_number, scope:, label:)
    link_to_new_search(ht_number, scope: scope, default_field: "ht_number", label: label)
  end
  alias_method :link_to_ht_number, :link_to_superorder

  # TODO: Add sort for volume count
  def link_to_volumes(ht_number, scope:, label:)
    link_to_new_search(ht_number, scope: scope, default_field: "superorder", label: label)
  end

  def link_to_creator(creator, scope:)
    link_to_new_search(creator, scope: scope, default_field: "creator_contributor_search")
  end

  def link_to_notation(notation, scope:)
    link_to_new_search(notation, scope: scope, default_field: "notation")
  end

  def link_to_subject(subject, scope:)
    link_to_new_search(subject, scope: scope, default_field: "subject_search")
  end

  def link_to_new_search(query_string, scope:, default_field:, label:nil)
    link_to (label || query_string), searches_path(
      search_request: Skala::SearchRequest.new(
        queries: {
          type: "query_string",
          query: query_string,
          default_field: default_field
        }
      ),
      scope: scope.id
    )
  end


  #
  # ------
  #


  def amazon_image_url(record, format: "THUMBZZZ")
    isbn = ensure_array(record.fields["isbn"]).first
    if isbn
      isbn = isbn.gsub("-", "")
      "https://images-na.ssl-images-amazon.com/images/P/#{isbn}.03.#{format}.jpg"
    end
  end


  #
  # ------
  #


  def journal_holdings(record, fullview:false)
    journal_holdings = ensure_array(record.fields["ldsX"])

    if journal_holdings.present?

      # remove "<strong>Zeitschriftensignatur<\/strong>..."
      cleaned_journal_holdings = journal_holdings.map { |journal_holding| journal_holding.gsub(/<strong>Zeitschriftensignatur<\/strong>.*/, '').gsub(/&lt;strong&gt;Zeitschriftensignatur&lt;\/strong&gt;.*/, '').strip }

      # check if the holdings statement includes a year < 1986
      has_holdings_statement_before_1986 = (cleaned_journal_holdings.map { |journal_holding| journal_holding.scan(/\d\d\d\d/) }.flatten.min.try(:<, '1986').try(:==, true))

      # location number
      journal_location_code = journal_location_code(record)

      # check if the journal has a closed stack location number
      has_closed_stack_location = %w(02 03 04 06 07 92 93 94 95 96 97 98).include?(journal_location_code)

      # check if the location number indicates some non local location, like 'ZfS'
      has_non_local_location = %w(86 88).include?(journal_location_code)

      if fullview
        content_tag(:ul) do
          cleaned_journal_holdings.map do |d|
            content_tag(:li, d.html_safe)
          end.join.html_safe
        end <<
        if (has_holdings_statement_before_1986 || (has_closed_stack_location)) && !has_non_local_location
          if has_holdings_statement_before_1986
            content_tag(:em, '*Zeitschriftenbestände bis einschließlich 1985 befinden sich in der Regel im Magazin. Um darauf zuzugreifen müssen Sie eine entsprechende Magazinbestellung aufgeben.')
          elsif has_closed_stack_location
            content_tag(:em, '*Es handelt sich um einen Magazinstandort. Um darauf zuzugreifen müssen Sie eine entsprechende Magazinbestellung aufgeben.')
          end << " " <<
          content_tag(:span, link_to('&raquo; Magazinbestellung aufgeben'.html_safe, new_closed_stack_order_path))
        end.to_s
      else
        cleaned_journal_holdings.join(', ')
      end
    end
  end

  def journal_location_code(record)
    journal_signature(record).try(:scan, /P\s(\d\d)/).try(:flatten).try(:first)
  end

  def journal_signature(record)
    signature = record.fields["signature"]

    if signature.present?
      if (match_result = signature.match(/\A(\w)(\d\d)\/(\d\d*)(\w)(\d\d*)\Z/)).present?
        "#{match_result[1]} #{match_result[2]}/#{match_result[3]} #{match_result[4]} #{match_result[5]}"
      elsif (match_result = signature.match(/\A(\d\d*)(\w)(\d\d*)\Z/)).present?
        "#{match_result[1]} #{match_result[2]} #{match_result[3]}"
      end
    end
  end


  #
  # ------
  #


  def is_journal?(record)
    record.fields["erscheinungsform"] == "journal"
  end

  def is_online_resource?(record)
    record.fields["materialtyp"] == "online_resource"
  end

  def show_availability?(record)
    signature(record).present? &&
    record.id.start_with?("PAD_ALEPH") &&
    !is_online_resource?(record) &&
    !is_journal?(record)
  end

  def is_superorder?(record)
    record.fields["is_superorder"] == true
  end


  #
  # ------
  #

  def ht_number(record)
    ensure_array(record.fields["ht_number"]).first
  end

  def title(record, scope:nil, search_request:nil)
    title = ensure_array(record.fields["title"]).join("; ")

    if scope && search_request
      link_to(title, record_path(record.id, scope: scope, search_request: search_request)).html_safe
    else
      title
    end
  end

  def creators(record, link:false, scope:nil)
    ensure_array(record.fields["creator_contributor_display"]).map do |creator|
      if link && scope
        link_to_creator(creator, scope: scope)
      else
        creator
      end
    end.join("; ").html_safe
  end

  def edition(record)
    ensure_array(record.fields["edition"]).first
  end

  def date_of_publication(record)
    ensure_array(record.fields["creationdate"]).first
  end

  def place_of_publication(record)
    ensure_array(record.fields["publisher"]).first.try(:split, ":").try(:[], 0).try(:strip)
  end

  def publisher(record)
    ensure_array(record.fields["publisher"]).first.try(:split, ":").try(:[], 1).try(:strip)
  end

  def signature(record, link: false)
    signature = ensure_array(record.fields["signature"]).first

    if signature
      if link
        link_to(signature, go_signature_path, target: "_blank").html_safe
      else
        signature
      end
    end
  end

  def format(record)
    ensure_array(record.fields["format"]).first
  end

  def language(record)
    ensure_array(record.fields["language"]).map{|l| t("languages.#{l}")}.join(", ")
  end

  def description(record)
    ensure_array(record.fields["description"]).join("<br/>").html_safe
  end

  def identifier(record)
    identifiers = []

    # ISBNS
    identifiers += [*record.fields["isbn"]].map{|isbn| "ISBN: #{isbn}"}
    # ISSNS
    identifiers += [*record.fields["issn"]].map{|issn| "ISSN: #{issn}"}
    # TODO
    # DOIs, HT Number, ...

    if identifiers.present?
      content_tag(:ul) do
        identifiers.map do |identifier|
          content_tag(:li) do
            identifier
          end
        end.join.html_safe
      end
    end
  end

  def notations(record, link:false, scope:nil)
    ensure_array(record.fields["notation"]).map do |notation|
      if link && scope
        link_to_notation(notation, scope: scope)
      else
        notation
      end
    end.join(", ").html_safe
  end

  def relations(record, link:false, scope:nil)
    relations = ensure_array(record.fields["relation"])

    if relations.present?
      content_tag(:ul) do
        relations.map do |relation|
          ht_number = relation["ht_number"]
          label     = relation["label"] || "n.a."

          content_tag(:li) do
            if link && scope && ht_number
              link_to_ht_number(ht_number, scope: scope, label: label)
            else
              label
            end
          end
        end.join.html_safe
      end
    end
  rescue
    binding.pry
  end

  def subject(record, link:false, scope:nil)
    subjects = ensure_array(record.fields["subject"])

    subjects.map do |subject|
      if link && scope
        link_to_subject(subject, scope: scope)
      else
        subject
      end
    end.join(", ").html_safe
  end

  def local_comments(record)
    add_data = ensure_array(record.fields["additional_data"]).first
    comments = ensure_array(add_data.try(:[], "local_comment"))
    comments.join("<br/>").html_safe
  end

  def source(record)
    # TODO: Implement me.
    nil
  end

  def links_to_toc(record)
    ensure_array(record.fields["link_to_toc"]).map.with_index do |link, index|
      label = index == 0 ? "Inhaltsverzeichnis anzeigen" : "Weiteres Inhaltsverzeichnis anzeigen"
      link_to label, link, target: "_blank"
    end.join("<br/>").html_safe
  end

  #
  # -------
  #

  def additional_record_info(record)
    parts = []
    parts << creators(record)
    parts << edition(record)
    parts << date_of_publication(record)

    parts.map(&:presence).compact.join(" - ")
  end

  def is_part_of(record, prefix_label:nil, scope:nil)
    if (superorders = ensure_array(record.fields["is_part_of"])).present?
      content_tag(:ul) do
        superorders.map do |superorder|
          content_tag(:li) do
            buffer = "#{prefix_label}"

            label  = superorder["label"]
            label << ": #{[*superorder["label_additions"]].join(", ")}" if superorder["label_additions"].present?
            label << "; #{superorder["volume_count"]}" if superorder["volume_count"].present?
            superorder["label"] = label

            if scope.present? && superorder["ht_number"].present?
              buffer << " #{link_to_superorder(superorder["ht_number"], scope: scope, label: superorder["label"])}"
            else
              buffer << " #{superorder["label"]}"
            end

            if scope.present? && superorder["ht_number"].present?
              buffer << " #{link_to_volumes(superorder["ht_number"], scope: scope, label: "(alle Bände)")}"
            end

            buffer.html_safe
          end
        end.join.html_safe
      end
    end
  end

end
