module JournalHelper

  def journal_stock(record)
    if record.journal_stock.present?
      record.journal_stock.map do |element|
        [
          [
            element["leading_text"],
            element["stock"].try(:join, "; ")
          ]
          .map(&:presence)
          .compact
          .join(": "),
          element["comment"]
        ]
        .map(&:presence)
        .compact
        .join(". ")
      end
      .join(", ")
    end
  end

  def before?(year, journal_stock)
    journal_stock["stock"] && journal_stock["stock"].join(" ").scan(/\d\d\d\d/).any? { |stock_year| stock_year < year.to_s }
  end

  def closed_stock_location?(journal_stock)
    journal_stock.any? do |element|
      if journal_stock["signature"].present?
        location_code = journal_stock["signature"][/P\d\d/][/\d\d/]
        %w(02 03 04 06 07 92 93 94 95 96 97 98).include?(location_code)
      end
    end
  end

  def located_outside_ubpb?(journal_stock)
    journal_stock.any? do |element|
      if journal_stock["signature"].present?
        location_code = journal_stock["signature"][/P\d\d/][/\d\d/]
        %w(86 88).include?(location_code)
      end
    end
  end

end
