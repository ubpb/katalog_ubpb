require "skala/aleph_adapter/get_record_items"
require_relative "../ubpb_aleph_adapter"

class KatalogUbpb::UbpbAlephAdapter::GetRecordItems < Skala::AlephAdapter::GetRecordItems
  def call(document_number)
    aleph_adapter_result = super(document_number)

    aleph_adapter_result.items = aleph_adapter_result.items.map do |_item|

      ubpb_item_class = Class.new(_item.class) do
        attribute :signature
        attribute :must_be_ordered_from_closed_stack, Virtus::Attribute::Boolean, default: false
      end

      ubpb_item = ubpb_item_class.new(_item)

      ubpb_item.tap do |_ubpb_item|
        add_availability!(_ubpb_item)
        add_ubpb_specific_status!(_ubpb_item)
        correct_journal_signatures!(_ubpb_item)
        set_location!(_ubpb_item)
        set_cso_status!(_ubpb_item)

        # depends on corrected signatures
        add_signature!(_ubpb_item)
      end
    end

    aleph_adapter_result.tap do |_aleph_adapter_result|
      sort_items!(_aleph_adapter_result)
    end
  end

  private

  def add_availability!(item)
    suppress_availability_for = ["Überordnung", "Zeitschriftenheft"]

    if suppress_availability_for.include?(item.fields["z30-material"])
      :unknown
    else
      item.fields["z30-item-status-code"].try do |_z30_item_status_code|
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
          if item.status == :on_shelf
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

  def add_signature!(item)
    item.signature = item.fields["z30-call-no"]
  end

  def add_ubpb_specific_status!(item)
    item.status = case item.fields["status"]
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

  def correct_journal_signatures!(item)
    if z30_call_no = item.fields["z30-call-no"].try(:sub, /\A\//, "").try(:[], /\A\d+\w\d+\Z/)
      collection_code = item.fields["z30-collection-code"].presence
      item.fields["z30-call-no"] = [collection_code ? "P#{collection_code}" : nil, z30_call_no.downcase].compact.join("/")
    end
  end

  def set_cso_status!(item)
    item.must_be_ordered_from_closed_stack = item.location.try(:downcase).try(:include?, "maga")
  end

  def set_location!(item)
    # Seminar/Tischapparate get their description by a script
    if ["Seminarapparat", "Tischapparat"].include?(item.fields["z30-item-status"])
      if (signature = item.fields["z30-call-no"]).present?
        Timeout::timeout(5) do
          Net::HTTP.get(URI("#{@adapter.x_services_url}/../ub-cgi/ausleiher_von_signatur.pl?#{signature}")).try do |_response|
            if ["IEMAN", "Sem", "Tisch"].any? { |_accepted_phrase| _response.include?(_accepted_phrase) }
              item.location = _response
            end
          end
        end
      end
    elsif ["Handapparat"].include?(item.fields["z30-item-status"])
      item.location = "Handapparat"
    else
      collection_code = item.fields["z30-collection-code"]
      notation = item.fields["z30-call-no"].try(:[], /\A[A-Z]{3}/)

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

  def sort_items!(get_record_items_result)
    get_record_items_result.items.sort_by!(&:id)
  end
end
