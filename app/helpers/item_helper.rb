module ItemHelper
  CLOSED_STOCK_THRESHOLD = 1986
  JOURNAL_SIGNATURE_PATTERN = /\d\d[a-zA-Z]\d{1,4}/ # don't use \w as it includes numbers

  def closed_stack?(record: nil, item: nil)
    item && item.must_be_ordered_from_closed_stack? ||
    item && journal_signature?(item.signature) &&
    (
      journal_locations(signature: item.signature).any? { |location| location[/magazin/i] } ||
      (record && record.year_of_publication.to_i < CLOSED_STOCK_THRESHOLD)
    )
  end

  def item_location(item)
    location =
      item.location.presence ||
      journal_signature?(item.signature) && journal_locations(
        signature: item.signature,
        stock: [item.record.year_of_publication].compact.presence
      )
      .presence
      .try(:join, "; ")

    case location
    when /zentrum.+sprachlehre|zfs/i
      link_to location, "http://www.uni-paderborn.de/zfs/wir-ueber-uns/ueber-die-mediathek/", target: "_blank"
    when /ieman/i
      link_to location, "http://www.ieman.de", target: "_blank"
    when /imt.+medien/i
      link_to location, "http://imt.uni-paderborn.de/servicecenter-medien/", target: "_blank"
    when /handapparat/i
      info = content_tag :span, "class" => "question-circle", "data-toggle" => "tooltip", "title" => "Dieses Medium steht in einem Handapparat. Besitzt die Universitätsbibliothek kein weiteres Exemplar dieses Titels, können Sie sich im Bedarfsfall an das Informationszentrum wenden.", "data-original-title" => "Handapparat", "data-placement" => "top" do
        fa_icon("question-circle")
      end

      "#{location} #{info}".html_safe
    else
      location
    end
  end

  def journal_signature?(signature)
    signature.try(:[], JOURNAL_SIGNATURE_PATTERN).present?
  end

end
