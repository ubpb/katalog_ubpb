require "skala/aleph_adapter/get_record_items"
require_relative "../ubpb_aleph_adapter"
require_relative "./item"

class KatalogUbpb::UbpbAlephAdapter::GetRecordItems < Skala::AlephAdapter::GetRecordItems
  def call(document_number, options = {})
    aleph_adapter_result = super

    aleph_adapter_result.items.map! do |_aleph_adapter_item|
      self.class.parent::Item.new(_aleph_adapter_item).tap do |_ubpb_aleph_adapter_item|
        doc = Nokogiri::XML(aleph_adapter_result.source).xpath("//item[contains(@href, '#{_ubpb_aleph_adapter_item.id}')]")

        set_availability!(_ubpb_aleph_adapter_item, doc)
        add_signature!(_ubpb_aleph_adapter_item, doc)
        set_ubpb_specific_status!(_ubpb_aleph_adapter_item, doc)
        add_location!(_ubpb_aleph_adapter_item, doc)
        set_cso_status!(_ubpb_aleph_adapter_item, doc)
      end
    end

    aleph_adapter_result.tap do |_aleph_adapter_result|
      sort_items!(_aleph_adapter_result)
    end
  end

  private

  def set_availability!(item, doc)
    suppress_availability_for = ["Überordnung", "Zeitschriftenheft"]

    if suppress_availability_for.include?(xpath(doc, "./z30/z30-material"))
      :unknown
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
        when "43" then :restricted_available # Handapparat
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
    end
    .try do |_item_availability|
      item.availability = _item_availability
    end
  end

  def add_signature!(item, doc)
    item.signature ||= begin
      if z30_call_no = xpath(doc, "./z30/z30-call-no").try(:sub, /\A\//, "").try(:[], /\A\d+\w\d+\Z/)
        collection_code = xpath(doc, "./z30-collection-code")
        item.signature = [collection_code ? "P#{collection_code}" : nil, z30_call_no.downcase].compact.join("/")
      else
        xpath(doc, "./z30/z30-call-no")
      end
    end
  end

  def set_ubpb_specific_status!(item, doc)
    item.status = case xpath(doc, "./status")
      when /Storniert/      then "cancelled"
      when /Reklamiert/     then "complained"
      when /Erwartet/       then "expected"
      when /In Bearbeitung/ then "in_process"
      when /Verlust/        then "lost"
      when /Vermisst/       then "missing"
      when /Bestellt/       then "on_order"
      else item.status
    end
  end

  def set_cso_status!(item, doc)
    add_location!(item, doc)
    item.must_be_ordered_from_closed_stack = item.location.try(:downcase).try(:include?, "maga")
  end

  def add_location!(item, doc)
    item.location ||= begin
      add_signature!(item, doc)

      # Seminar/Tischapparate get their description by a script
      if ["Seminarapparat", "Tischapparat"].include?(item.item_status)
        if item.signature.present?
          Timeout::timeout(5) do
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
        notation = xpath(doc, "./z30/z30-call-no").try(:[], /\A[A-Z]{2,3}/)

        if collection_code && notation
          KatalogUbpb::UbpbAlephAdapter::LOCATION_LOOKUP_TABLE.find do |_row|
            _row[:standortkennziffern].include?(collection_code) && _row[:systemstellen].include?(notation)
          end
          .try do |_row|
            item.location = _row[:location]
          end
        end
      end
    end
  end

  def sort_items!(get_record_items_result)
    get_record_items_result.items.sort_by!(&:id)
  end

  def xpath(doc, xpath)
    doc.at_xpath(xpath).try(:content).presence
  end
end
