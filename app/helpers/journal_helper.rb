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

  def any_before?(year, journal_stocks)
    journal_stocks.try(:any?) { |journal_stock| before?(year, journal_stock) }
  end

  def any_closed_stock_location?(journal_stocks)
    journal_stocks.try(:any?) { |journal_stock| closed_stock_location?(journal_stock) }
  end

  def before?(year, journal_stock)
    journal_stock["stock"] && journal_stock["stock"].join(" ").scan(/\d\d\d\d/).any? { |stock_year| stock_year < year.to_s }
  end

  def closed_stock_location?(journal_stock)
    journal_stock.any? do |element|
      location_code = journal_stock.try(:[], "signature").try(:[], /P\d\d/).try(:[], /\d\d/)
      %w(02 03 04 06 07 92 93 94 95 96 97 98).include?(location_code)
    end
  end

  def located_outside_ubpb?(journal_stock)
    journal_stock.any? do |element|
      location_code = journal_stock.try(:[], "signature").try(:[], /P\d\d/).try(:[], /\d\d/)
      %w(86 88).include?(location_code)
    end
  end

  def none_located_outside_ubpb?(journal_stocks)
    journal_stocks.try(:all?) { |journal_stock| !located_outside_ubpb?(journal_stock) }
  end

end
