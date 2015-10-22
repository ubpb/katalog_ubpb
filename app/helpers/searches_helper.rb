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

  def link_to_next_page(scope, search_request, total_hits)
    from = search_request.from + search_request.size
    enabled = from < total_hits

    if enabled
      link_to_page(scope, search_request, from) do
        fa_icon("angle-right")
      end
    end
  end

  def page_stats(scope, search_request, total_hits)
    page_start = search_request.from + 1
    page_end   = search_request.from + search_request.size
    page_end   = total_hits if page_end > total_hits

    link_to_page(scope, search_request, 0) do
      content_tag :span, class: "page-stats" do
        "#{page_start} – #{page_end} von #{total_hits}"
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

  def amazon_image_url(hit, format: "THUMBZZZ")
    isbn = [*hit.fields["isbn"]].first
    if isbn
      isbn = isbn.gsub("-", "")
      "https://images-na.ssl-images-amazon.com/images/P/#{isbn}.03.#{format}.jpg"
    end
  end

  def journal_holdings(hit, options = {})
    journal_holdings = [*hit.fields["ldsX"]]

    if journal_holdings.present?

      # remove "<strong>Zeitschriftensignatur<\/strong>..."
      cleaned_journal_holdings = journal_holdings.map { |journal_holding| journal_holding.gsub(/<strong>Zeitschriftensignatur<\/strong>.*/, '').gsub(/&lt;strong&gt;Zeitschriftensignatur&lt;\/strong&gt;.*/, '').strip }

      # check if the holdings statement includes a year < 1986
      has_holdings_statement_before_1986 = (cleaned_journal_holdings.map { |journal_holding| journal_holding.scan(/\d\d\d\d/) }.flatten.min.try(:<, '1986').try(:==, true))

      # location number
      journal_location_code = journal_location_code(hit)

      # check if the journal has a closed stack location number
      has_closed_stack_location = %w(02 03 04 06 07 92 93 94 95 96 97 98).include?(journal_location_code)

      # check if the location number indicates some non local location, like 'ZfS'
      has_non_local_location = %w(86 88).include?(journal_location_code)

      if options[:as_html]
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

  def journal_location_code(hit)
    journal_signature(hit).try(:scan, /P\s(\d\d)/).try(:flatten).try(:first)
  end

  def journal_signature(hit)
    signature = hit.fields["signature"]

    if signature.present?
      if (match_result = signature.match(/\A(\w)(\d\d)\/(\d\d*)(\w)(\d\d*)\Z/)).present?
        "#{match_result[1]} #{match_result[2]}/#{match_result[3]} #{match_result[4]} #{match_result[5]}"
      elsif (match_result = signature.match(/\A(\d\d*)(\w)(\d\d*)\Z/)).present?
        "#{match_result[1]} #{match_result[2]} #{match_result[3]}"
      end
    end
  end

  def is_journal?(hit)
    hit.fields["erscheinungsform"] == "journal"
  end

  def is_online_resource?(hit)
    hit.fields["materialtyp"] == "online_resource"
  end

  def show_availability?(hit)
    hit.id.start_with?("PAD_ALEPH") && !is_online_resource?(hit) && !is_journal?(hit)
  end

end
