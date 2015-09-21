require_relative "../get_record_items"

module KatalogUbpb
  class UbpbAlephAdapter::GetRecordItems::AddAvailability
    def call!(record_item)
      source = WeakXml.new(record_item["_source"])
      suppress_availability_for = ["Überordnung", "Zeitschriftenheft"]

      unless suppress_availability_for.include?(source.find("<z30-material>").content)
        source.find("<z30-item-status-code>").content
        .try do |_z30_item_status_code|
          case _z30_item_status_code
          #
          # restricted_available (under any conditions)
          #
          when "23" then "restricted_available" # Tischapparat
          when "32" then "restricted_available" # Nicht ausleihbar
          when "33" then "restricted_available" # Seminarapparat
          when "37" then "restricted_available" # Nicht ausleihbar
          when "38" then "restricted_available" # Nicht ausleihbar
          when "41" then "restricted_available" # Nicht ausleihbar
          when "42" then "restricted_available" # Nicht ausleihbar
          when "43" then "restricted_available" # Handapparat
          when "44" then "restricted_available" # Nicht ausleihbar
          when "48" then "restricted_available" # Nicht ausleihbar
          when "49" then "restricted_available" # Nicht ausleihbar
          when "50" then "restricted_available" # Nicht ausleihbar
          when "55" then "restricted_available" # Nicht ausleihbar
          when "58" then "restricted_available" # Nicht ausleihbar
          when "60" then "restricted_available" # Nicht ausleihbar
          when "68" then "restricted_available" # Magazin-Präsenzausleihe
          else
            #
            # if present
            #
            if record_item["fields"]["status"].try(:include?, "on_shelf")
              case _z30_item_status_code
              #
              # available
              #
              when "20" then "available" # "Normalausleihe"
              when "21" then "available" # "Magazinausleihe
              when "24" then "available" # "Normalausleihe
              when "25" then "available" # "Normalausleihe
              when "26" then "available" # "Normalausleihe
              when "27" then "available" # "Magazinausleihe
              when "53" then "available" # "4-Wochen-Ausleihe
              when "63" then "available" # "6-Monats-Ausleihe
              when "73" then "available" # "FL Abholung, Keine Verl.
              when "74" then "available" # "FL Lesesaal, Keine Verl.
              #
              # restricted_available
              #
              when "30" then "restricted_available" # Kurzausleihe
              when "31" then "restricted_available" # Magazin-Kurzausleihe
              when "34" then "restricted_available" # Kurzausleihe
              when "35" then "restricted_available" # Kurzausleihe
              when "36" then "restricted_available" # Kurzausleihe
              when "40" then "restricted_available" # Kurzausleihe
              when "47" then "restricted_available" # Magazin-Kurzausleihe
              when "53" then "restricted_available" # 4-Wochen-Ausleihe
              when "61" then "restricted_available" # Magazin-5-Tage-Ausleihe
              end
            #
            # if not present
            #
            else
              "not_available"
            end
          end
        end
        .try do |_availability|
          record_item["fields"]["availability"] ||= _availability
        end
      end
    end
  end
end
