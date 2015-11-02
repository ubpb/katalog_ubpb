module ItemHelper

  def item_location(item)
    location = item.location.presence
    case location
    when /zentrum.+sprachlehre|zfs/i
      link_to location, "http://www.uni-paderborn.de/zfs/wir-ueber-uns/mediathek/", target: "_blank"
    when /ieman/i
      link_to location, "http://www.ieman.de", target: "_blank"
    when /imt.+medien/i
      link_to location, "http://imt.uni-paderborn.de/servicecenter-medien/", target: "_blank"
    when /handapparat/i
      link_to location, "#", rel: "popover", "data-content" => "Dieses Medium steht in einem Handapparat. Besitzt die Universitätsbibliothek kein weiteres Exemplar dieses Titels, können Sie sich im Bedarfsfall an das Informationszentrum wenden.", "data-original-title" => "Handapparat", "data-placement" => "top"
    else
      location
    end
  end

end
