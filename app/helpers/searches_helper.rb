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

  def link_to_superorder(scope, superorder)
    link_to superorder["label"], searches_path(
      search_request: Skala::SearchRequest.new(
        queries: {
          type: "query_string",
          query: superorder["ht_number"],
          default_field: "ht_number"
        }
      ),
      scope: scope.id
    )
  end

  def link_to_creator(creator, scope:scope)
    link_to creator, searches_path(
      search_request: Skala::SearchRequest.new(
        queries: {
          type: "query_string",
          query: creator,
          default_field: "creator_contributor_search"
        }
      ),
      scope: scope.id
    )
  end

  # TODO: Add sort for volume count
  def link_to_volumes(scope, superorder)
    link_to searches_path(
      search_request: Skala::SearchRequest.new(
        queries: {
          type: "query_string",
          query: superorder["ht_number"],
          default_field: "superorder"
        }
      ),
      scope: scope.id
    ) do
      "(alle Bände)"
    end
  end

  def amazon_image_url(record, format: "THUMBZZZ")
    isbn = [*record.fields["isbn"]].first
    if isbn
      isbn = isbn.gsub("-", "")
      "https://images-na.ssl-images-amazon.com/images/P/#{isbn}.03.#{format}.jpg"
    end
  end

  def journal_holdings(record, fullview:false)
    journal_holdings = [*record.fields["ldsX"]]

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
          end <<
          content_tag(:div, link_to('&raquo; Magazinbestellung aufgeben'.html_safe, "#")) # TODO: Add path
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

  #
  # ------
  #

  def title(record, scope:nil, search_request:nil)
    title = [*record.fields["title"]].join("; ").presence

    if scope && search_request
      link_to(title, record_path(record.id, scope: scope, search_request: search_request)).html_safe
    else
      title
    end
  end

  def creators(record, link:false, scope:nil)
    [*record.fields["creator_contributor_display"]].map do |creator|
      if link && scope
        link_to_creator(creator, scope: scope)
      else
        creator
      end
    end.join("; ").html_safe
  end

  def edition(record)
    record.fields["edition"].presence
  end

  def date_of_publication(record)
    record.fields["creationdate"].presence
  end

  def place_of_publication(record)
    record.fields["publisher"].try(:split, ":")[0].try(:strip).presence
  end

  def publisher(record)
    record.fields["publisher"].try(:split, ":")[1].try(:strip).presence
  end

  def signature(record, link: false)
    signature = record.fields["signature"]

    if signature
      if link
        link_to(signature, "http://www.ub.uni-paderborn.de/lernen_und_arbeiten/bestaende/medienaufstellung-systemstelle.shtml", target: "_blank").html_safe
      else
        signature
      end
    end
  end

  def format(record)
    record.fields["format"].presence
  end

  def language(record)
    [*record.fields["language"]].map{|l| t("languages.#{l}")}.join(", ").presence
  end

  def description(record)
    [*record.fields["description"]].join("<br/>").presence.try(:html_safe)
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
    if (superorders = record.fields["is_part_of"]).present?
      content_tag :ul do
        [*[superorders]].flatten.map do |superorder|
          content_tag(:li) do
            buffer = "#{prefix_label}"

            label  = superorder["label"]
            label << ": #{[*superorder["label_additions"]].join(", ")}" if superorder["label_additions"].present?
            label << "; #{superorder["volume_count"]}" if superorder["volume_count"].present?
            superorder["label"] = label

            if scope.present? && superorder["ht_number"].present?
              buffer << " #{link_to_superorder(scope, superorder)}"
            else
              buffer << " #{superorder["label"]}"
            end

            if scope.present? && superorder["ht_number"].present?
              buffer << " #{link_to_volumes(scope, superorder)}"
            end

            buffer.html_safe
          end
        end.join.html_safe
      end
    end
  end

end
