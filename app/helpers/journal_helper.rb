module JournalHelper

  def journal_stock(record, fullview: false)
    if record.journal_stock.present?
      return record.journal_stock.map { |element| element["stock"].join("; ")}.join(", ").html_safe unless fullview

      [
        content_tag(:ul) do
          record.journal_stock.map do |element|
            content_tag(:li, style: "position: relative;") do
              [
                content_tag(:div, style: "padding-right: 140px;") do
                  [
                    element["leading_text"].present? ? content_tag(:span, element["leading_text"]) : nil,
                    [
                      element["stock"].present? ? content_tag(:span, element["stock"].try(:join, "; ")) : nil,
                      element["comment"].present? ? content_tag(:span, element["comment"]) : nil
                    ]
                    .map(&:presence)
                    .compact
                    .join(". ")
                    .html_safe
                  ]
                  .map(&:presence)
                  .compact
                  .join(": ")
                  .html_safe
                end,
                if element["signature"].present?
                  content_tag(:div, style: "position: absolute; top: 0; right: 4px;") do
                    [
                      content_tag(:span, "Signatur: "),
                      link_to(element["signature"], go_signature_path, style: "font-weight: bold", target: "_blank").html_safe
                    ]
                    .join
                    .html_safe
                  end
                end
              ]
              .map(&:presence)
              .compact
              .join
              .html_safe
            end
          end
          .join
          .html_safe
        end,
        if none_located_outside_ubpb?(record.journal_stock) && (any_before?(1986, record.journal_stock) || any_closed_stock_location?(record.journal_stock))
          [
            if any_before?(1986, record.journal_stock)
              content_tag(:em, '*Zeitschriftenbestände bis einschließlich 1985 befinden sich in der Regel im Magazin. Um darauf zuzugreifen müssen Sie eine entsprechende Magazinbestellung aufgeben.')
            elsif any_closed_stock_location?(record.journal_stock)
              content_tag(:em, '*Es handelt sich um einen Magazinstandort. Um darauf zuzugreifen müssen Sie eine entsprechende Magazinbestellung aufgeben.')
            end,
            content_tag(:span, link_to('&raquo; Magazinbestellung aufgeben'.html_safe, current_user ? new_closed_stack_order_path(z1: record.signature) : new_session_path(return_to: current_path, redirect: true)))
          ]
          .join(" ")
          .html_safe
        end
      ]
      .join
      .html_safe
    end
  end

  private

  def any_before?(year, journal_stocks)
    journal_stocks.any? { |journal_stock| before?(year, journal_stock) }
  end

  def any_closed_stock_location?(journal_stocks)
    journal_stocks.any? { |journal_stock| closed_stock_location?(journal_stock) }
  end

  def before?(year, journal_stock)
    journal_stock["stock"].join(" ").scan(/\d\d\d\d/).any? { |stock_year| stock_year < year.to_s }
  end

  def closed_stock_location?(journal_stock)
    journal_stock.any? do |element|
      location_code = journal_stock["signature"][/P\d\d/][/\d\d/]
      %w(02 03 04 06 07 92 93 94 95 96 97 98).include?(location_code)
    end
  end

  def located_outside_ubpb?(journal_stock)
    journal_stock.any? do |element|
      location_code = journal_stock["signature"][/P\d\d/][/\d\d/]
      %w(86 88).include?(location_code)
    end
  end

  def none_located_outside_ubpb?(journal_stocks)
    journal_stocks.all? { |journal_stock| !located_outside_ubpb?(journal_stock) }
  end

end
