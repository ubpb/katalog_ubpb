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

  def has_p00_location?(journal_stocks)
    journal_stocks.try(:any?) { |journal_stock| journal_stock["signature"]&.starts_with?("P00") } || false
  end

  def has_only_mono_signatures?(journal_stocks)
    journal_stocks.try(:all?) { |journal_stock| has_mono_signature?(journal_stock) }
  end

  def has_mono_signature?(journal_stock)
    journal_stock["signature"]&.match(/\AP\d\d[A-Z]{3,4}/)
  end

  def mono_signature_from_journal_stock_signature(signature)
    signature.try(:[], /[A-Z]{3,4}.*/)
  end

  def collection_code_from_journal_stock_signature(signature)
    signature&.match(/\AP(\d\d).*/).try(:[], 1)
  end

  def location_for_journal_stock_with_mono_signature(journal_stock)
    collection_code = collection_code_from_journal_stock_signature(journal_stock["signature"])
    notation = mono_signature_from_journal_stock_signature(journal_stock["signature"]).try(:[], /\A[A-Z]{3,4}/)

    if collection_code && notation
      LOCATION_LOOKUP_TABLE.find do |_row|
        systemstellen_range = _row[:systemstellen]
        standortkennziffern = _row[:standortkennziffern]

        if systemstellen_range.present? && systemstellen_range.first.present? && systemstellen_range.last.present? && standortkennziffern.present?
          # Expand systemstellen and notation to 4 chars to make ruby range include? work in this case.
          justified_systemstellen_range = (systemstellen_range.first.ljust(4, "A") .. systemstellen_range.last.ljust( 4, "A"))
          justified_notation = notation.ljust(4, "A")

          standortkennziffern.include?(collection_code) && justified_systemstellen_range.include?(justified_notation)
        end
      end.try do |_row|
        _row[:location]
      end
    end
  end

end
