module JournalHelper

  def journal_holdings(record, fullview:false)
    journal_holdings = record.journal_holdings

    if journal_holdings.present?

      # remove "<strong>Zeitschriftensignatur<\/strong>..."
      cleaned_journal_holdings = journal_holdings.map { |journal_holding| journal_holding.gsub(/<strong>Zeitschriftensignatur<\/strong>.*/, '').gsub(/&lt;strong&gt;Zeitschriftensignatur&lt;\/strong&gt;.*/, '').strip }

      # check if the holdings statement includes a year < 1986
      has_holdings_statement_before_1986 = (cleaned_journal_holdings.map { |journal_holding| journal_holding.scan(/\d\d\d\d/) }.flatten.min.try(:<, '1986').try(:==, true))

      # extend infos to open intervals
      # TODO:
      #cleaned_journal_holdings.map!{|h| h.strip! ; (h =~ /\-\Z/) ? "#{h} heute" : h}

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
          content_tag(:span, link_to('&raquo; Magazinbestellung aufgeben'.html_safe, new_closed_stack_order_path(z1: record.signature)))
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
    signature = record.signature

    if signature.present?
      if (match_result = signature.match(/\A(\w)(\d\d)\/(\d\d*)(\w)(\d\d*)\Z/)).present?
        "#{match_result[1]} #{match_result[2]}/#{match_result[3]} #{match_result[4]} #{match_result[5]}"
      elsif (match_result = signature.match(/\A(\d\d*)(\w)(\d\d*)\Z/)).present?
        "#{match_result[1]} #{match_result[2]} #{match_result[3]}"
      end
    end
  end

end
