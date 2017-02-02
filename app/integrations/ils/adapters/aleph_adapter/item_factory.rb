module Ils::Adapters
  class AlephAdapter
    class ItemFactory

      def self.build(xml, item_count: 1)
        self.new.build(xml, item_count: item_count)
      end

      def build(node, item_count: 1)
        Ils::Item.new(
          id: get_id(node),
          signature: get_signature(node),
          collection_code: get_collection_code(node),
          item_status_code: get_item_status_code(node),
          process_status_code: get_process_status_code(node),
          process_status: get_process_status(node),
          availability_status: get_availability_status(node, item_count),
          due_date: get_due_date(node),
          note: get_note(node),
          hold_request_count: get_hold_request_count(node),
          hold_request_allowed: get_hold_request_allowed(node),
        )
      end

    private

      def get_id(node)
        node["href"][/[^\/]+\Z/][/\A[^?]+/]
      end

      def get_signature(node)
        material        = node.at_xpath("z30/z30-material")&.text
        collection_code = get_collection_code(node)
        signature       = node.at_xpath("z30/z30-call-no")&.text || node.at_xpath("z30/z30-call-no-2")&.text

        if material == "Zeitschriftenheft" && collection_code.present?
          signature = "P#{collection_code}/#{signature}"
        end

        signature
      end

      def get_collection_code(node)
        node.at_xpath("z30-collection-code")&.text || node.at_xpath("z30/z30-collection-code")&.text
      end

      def get_item_status_code(node)
        node.at_xpath("z30-item-status-code")&.text || node.at_xpath("z30/z30-item-status-code")&.text
      end

      def get_process_status_code(node)
        node.at_xpath("z30-item-process-status-code")&.text || node.at_xpath("z30/z30-item-process-status-code")&.text
      end

      def get_process_status(node)
        process_status_code = get_process_status_code(node)
        raw_status = node.at_xpath("status")&.text

        process_status = if process_status_code.present?
          case process_status_code
          when "GG" then :in_process # In Bearbeitung
          when "MS" then :missing    # Vermisst
          when "BP" then :unknown    # Band komplett
          when "BD" then :bookbinder # Beim Buchbinder
          when "LL" then :scrapped   # Ausgesondert
          when "IU" then :in_process # Interne umarbeitung
          when "LE" then :in_process # Lückenergänzung
          when "MI" then :lost       # Verlust
          when "BW" then :unknown    # Bestellwunsch
          when "BS" then :ordered    # Bestellt
          when "EX" then :expected   # Erwatet
          when "RE" then :unknown    # Reklamiert
          when "IV" then :in_process # In Bearbeitung
          when "ST" then :unknown    # Storniert
          when "NP" then :unknown    # Nicht publiziert
          when "IL" then :unknown    # Fernleihmaterial
          else :unknown
          end
        elsif process_status_code.blank? && raw_status.present?
          case raw_status
          when ""                    then :on_shelf         # Exemplar steht im Regal
          when /on shelf/i           then :on_shelf         # Exemplar steht im Regal
          when /\A\d\d\/\d\d\/\d\d/  then :loaned           # Exemplar ist entliehen
          when /effective due date/i then :loaned           # Exemplar ist entliehen (Rückruf)
          when /reshelving/i         then :reshelving       # Exemplar wird zurückgestellt
          when /on hold/i            then :on_hold          # Exemplar ist bereitgestellt
          when /expected/i           then :expected         # Exemplar wird erwartet
          when /claimed returned/i   then :claimed_returned # Exemplar ist angeblich zurück
          when /lost/i               then :lost             # Exemplar ist verloren gegangen
          end
        end

        process_status || :unknown
      end

      def get_availability_status(node, item_count)
        item_status_code = get_item_status_code(node)
        process_status   = get_process_status(node)
        material         = node.at_xpath("z30/z30-material")&.text

        availability = case item_status_code
          when "20" then :available                                                 # "Normalausleihe"
          when "21" then :available                                                 # "Magazinausleihe
          when "23" then :restricted_available                                      # Tischapparat
          when "24" then :available                                                 # "Normalausleihe
          when "25" then :available                                                 # "Normalausleihe
          when "26" then :available                                                 # "Normalausleihe
          when "27" then :available                                                 # "Magazinausleihe
          when "30" then :restricted_available                                      # Kurzausleihe
          when "31" then :restricted_available                                      # Magazin-Kurzausleihe
          when "32" then :restricted_available                                      # Nicht ausleihbar
          when "33" then :restricted_available                                      # Seminarapparat
          when "34" then :restricted_available                                      # Kurzausleihe
          when "35" then :restricted_available                                      # Kurzausleihe
          when "36" then :restricted_available                                      # Kurzausleihe
          when "37" then :restricted_available                                      # Nicht ausleihbar
          when "38" then :restricted_available                                      # Nicht ausleihbar
          when "40" then :restricted_available                                      # Kurzausleihe
          when "41" then :restricted_available                                      # Nicht ausleihbar
          when "42" then :restricted_available                                      # Nicht ausleihbar
          when "43" then (item_count == 1) ? :restricted_available : :not_available # Handapparat
          when "44" then :restricted_available                                      # Nicht ausleihbar
          when "47" then :restricted_available                                      # Magazin-Kurzausleihe
          when "48" then :restricted_available                                      # Nicht ausleihbar
          when "49" then :restricted_available                                      # Nicht ausleihbar
          when "50" then :restricted_available                                      # Nicht ausleihbar
          when "53" then :restricted_available                                      # 4-Wochen-Ausleihe
          when "55" then :restricted_available                                      # Nicht ausleihbar
          when "58" then :restricted_available                                      # Nicht ausleihbar
          when "60" then :restricted_available                                      # Nicht ausleihbar
          when "61" then :restricted_available                                      # Magazin-5-Tage-Ausleihe
          when "63" then :available                                                 # "6-Monats-Ausleihe
          when "68" then :restricted_available                                      # Magazin-Präsenzausleihe
          when "73" then :available                                                 # "FL Abholung, Keine Verl.
          when "74" then :available                                                 # "FL Lesesaal, Keine Verl.
          else :unknown
        end

        if process_status != :on_shelf && process_status != :reshelving
          availability = :not_available
        end

        if ["Überordnung", "Zeitschriftenheft"].include?(material)
          availability = :unknown
        end

        availability
      end

      def get_due_date(node)
        due_date_str = (node.at_xpath("status")&.text || "")[/\d\d\/\d\d\/\d\d/]
        Date.strptime(due_date_str, "%d/%m/%y") if due_date_str
      end

      def get_note(node)
        notes = [
          node.at_xpath("z30/z30-description")&.text,
          node.at_xpath("z30/z30-note-opac")&.text
        ].map(&:presence).compact.join("\n").presence
      end

      def get_hold_request_count(node)
        if queue = node.at_xpath("queue")&.text
          queue[/\A\d+/]&.to_i # example: "1 request(s) of 11 items."
        end || 0
      end

      def get_hold_request_allowed(node)
        item_status_code = get_item_status_code(node)
        allowed          = node.at_xpath("info[@type='HoldRequest']/@allowed")&.text == "Y"

        case item_status_code
        when "23" then false # Tischapparat
        when "33" then false # Seminarapparat
        when "43" then false # Handapparat
        else
          allowed
        end
      end

    end
  end
end
