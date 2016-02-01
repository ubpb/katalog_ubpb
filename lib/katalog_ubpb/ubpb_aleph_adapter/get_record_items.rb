require "skala/aleph_adapter/get_record_items"
require_relative "../ubpb_aleph_adapter"
require_relative "../item"

class KatalogUbpb::UbpbAlephAdapter::GetRecordItems < Skala::AlephAdapter::GetRecordItems
  def call(document_number, options = {})
    aleph_adapter_result = super

    aleph_adapter_result.items.map! do |_item|
      _item = KatalogUbpb::Item.new(_item)

      doc = Nokogiri::XML(aleph_adapter_result.source).xpath("//item[contains(@href, '#{_item.id}')]")

      set_ubpb_specific_status!(_item, doc)
      set_availability!(_item, doc, aleph_adapter_result.items)
      set_hold_request_can_be_created!(_item, doc)
      add_signature!(_item, doc)
      add_location!(_item, doc)
      set_closed_stack!(_item, doc)

      _item
    end

    aleph_adapter_result.tap do |_aleph_adapter_result|
      filter_items!(_aleph_adapter_result.items)
      sort_items!(_aleph_adapter_result.items)
    end
  end

  private

  def set_availability!(item, doc, items)
    suppress_availability_for = ["Überordnung", "Zeitschriftenheft"]

    if suppress_availability_for.include?(xpath(doc, "./z30/z30-material"))
      :unknown
    elsif [:cancelled, :complained, :expected, :in_process, :lost, :missing, :on_order].include?(item.status)
      :not_available
    else
      xpath(doc, "./z30-item-status-code").try do |_z30_item_status_code|
        case _z30_item_status_code
        #
        # restricted_available (under any conditions)
        #
        when "23" then :restricted_available # Tischapparat
        when "32" then :restricted_available # Nicht ausleihbar
        when "33" then :restricted_available # Seminarapparat
        when "37" then :restricted_available # Nicht ausleihbar
        when "38" then :restricted_available # Nicht ausleihbar
        when "41" then :restricted_available # Nicht ausleihbar
        when "42" then :restricted_available # Nicht ausleihbar
        when "43" then (items.count == 1) ? :restricted_available : :not_available # Handapparat
        when "44" then :restricted_available # Nicht ausleihbar
        when "48" then :restricted_available # Nicht ausleihbar
        when "49" then :restricted_available # Nicht ausleihbar
        when "50" then :restricted_available # Nicht ausleihbar
        when "55" then :restricted_available # Nicht ausleihbar
        when "58" then :restricted_available # Nicht ausleihbar
        when "60" then :restricted_available # Nicht ausleihbar
        when "68" then :restricted_available # Magazin-Präsenzausleihe
        else
          #
          # if present
          #
          if item.status == :on_shelf || item.status == :reshelving
            case _z30_item_status_code
            #
            # available
            #
            when "20" then :available # "Normalausleihe"
            when "21" then :available # "Magazinausleihe
            when "24" then :available # "Normalausleihe
            when "25" then :available # "Normalausleihe
            when "26" then :available # "Normalausleihe
            when "27" then :available # "Magazinausleihe
            when "53" then :available # "4-Wochen-Ausleihe
            when "63" then :available # "6-Monats-Ausleihe
            when "73" then :available # "FL Abholung, Keine Verl.
            when "74" then :available # "FL Lesesaal, Keine Verl.
            #
            # restricted_available
            #
            when "30" then :restricted_available # Kurzausleihe
            when "31" then :restricted_available # Magazin-Kurzausleihe
            when "34" then :restricted_available # Kurzausleihe
            when "35" then :restricted_available # Kurzausleihe
            when "36" then :restricted_available # Kurzausleihe
            when "40" then :restricted_available # Kurzausleihe
            when "47" then :restricted_available # Magazin-Kurzausleihe
            when "53" then :restricted_available # 4-Wochen-Ausleihe
            when "61" then :restricted_available # Magazin-5-Tage-Ausleihe
            end
          #
          # if not present
          #
          else
            :not_available
          end
        end
      end
    end.try do |_item_availability|
      item.availability = _item_availability
    end
  end

  def add_signature!(item, doc)
    item.signature ||= begin
      if z30_call_no = xpath(doc, "./z30/z30-call-no").try(:sub, /\A\//, "").try(:[], /\A\d+\w[\d\w-]+\Z/)
        collection_code = xpath(doc, "./z30-collection-code")
        item.signature = [collection_code ? "P#{collection_code}" : nil, z30_call_no].compact.join("/")
      else
        xpath(doc, "./z30/z30-call-no")
      end
    end
  end

  def set_hold_request_can_be_created!(item, doc)
    if item.hold_request_can_be_created == true # only of the generic method has determined it is
      item_status_blacklist = ["Tischapparat", "Seminarapparat", "Handapparat"]

      if item_status_blacklist.include?(doc.at_xpath("./z30/z30-item-status").try(:content))
        item.hold_request_can_be_created = false
      end
    end
  end

  def set_ubpb_specific_status!(item, doc)
    item.status = case xpath(doc, "./status")
      when /Storniert/      then :cancelled
      when /Reklamiert/     then :complained
      when /Erwartet/       then :expected
      when /In Bearbeitung/ then :in_process
      when /Verlust/        then :lost
      when /Vermisst/       then :missing
      when /Bestellt/       then :on_order
      else item.status
    end
  end

  def set_closed_stack!(item, doc)
    collection = xpath(doc, "./z30/z30-collection")
    item.must_be_ordered_from_closed_stack = collection.try(:downcase).try(:include?, "maga") &&
      (item.availability == :available || item.availability == :restricted_available)
  end

  def add_location!(item, doc)
    item.location ||= begin
      add_signature!(item, doc)

      # Seminar/Tischapparate get their description by a script
      if ["Seminarapparat", "Tischapparat"].include?(item.item_status)
        if item.signature.present?
          Timeout::timeout(10) do
            Net::HTTP.get(URI("#{@adapter.x_services_url}/../ub-cgi/ausleiher_von_signatur.pl?#{item.signature}")).try do |_response|
              if ["IEMAN", "Sem", "Tisch"].any? { |_accepted_phrase| _response.include?(_accepted_phrase) }
                item.location = _response
              end
            end
          end
        end
      elsif ["Handapparat"].include?(item.item_status)
        item.location = "Handapparat"
      else
        collection_code = xpath(doc, "./z30-collection-code")
        notation = xpath(doc, "./z30/z30-call-no").try(:[], /\A[A-Z]{1,3}/)

        if collection_code && notation
          KatalogUbpb::UbpbAlephAdapter::LOCATION_LOOKUP_TABLE.find do |_row|
            systemstellen_range = _row[:systemstellen]
            standortkennziffern = _row[:standortkennziffern]

            if systemstellen_range.present? && systemstellen_range.first.present? && systemstellen_range.last.present? && standortkennziffern.present?
              # Expand systemstellen and notation to 4 chars to make ruby range include? work in this case.
              justified_systemstellen_range = (systemstellen_range.first.ljust(4, "A") .. systemstellen_range.last.ljust( 4, "A"))
              justified_notation = notation.ljust(4, "A")

              standortkennziffern.include?(collection_code) && justified_systemstellen_range.include?(justified_notation)
            end
          end
          .try do |_row|
            item.location = _row[:location]
          end
        end
      end
    end
  end

  def filter_items!(items)
    # reject all items which end with "-..."
    items.reject! { |item| item.signature.present? && item.signature[/-\.\.\.\Z/] }
  end

  def sort_items!(items)
    items.sort! do |x, y|
      if x.signature.blank?
        0 <=> -1
      elsif y.signature.blank?
        -1 <=> 0
      else
        (x.signature.split("+")[1] || 0).to_i <=> (y.signature.split("+")[1] || 0).to_i
      end
    end
  end

  def xpath(doc, xpath)
    doc.at_xpath(xpath).try(:content).presence
  end
end
