require_relative "../get_record_items"

module KatalogUbpb
  class UbpbAlephAdapter::GetRecordItems::ExtendDescription
    def initialize(x_services_url)
      @x_services_url = x_services_url
    end

    def call!(record_item)
      description_description =
      # Handapparat et. al. get their title as description so it can be translated later on by the frontend
      if (description_title = record_item["fields"]["description"]["title"]) == "Handapparat"
        description_title
      # Seminar/Tischapparate get their description by a script
      elsif description_title == "Seminarapparat" || description_title == "Tischapparat"
        if (signature = record_item["fields"]["signature"]).present?
          Faraday.get("#{@x_services_url}/../ub-cgi/ausleiher_von_signatur.pl?#{signature}").try do |_response|
            if ["IEMAN", "Sem", "Tisch"].any? { |_accepted_phrase| _response.body.include?(_accepted_phrase) }
              _response.body
            end
          end
        end
      end

      if description_description
        record_item["fields"]["description"]["description"] = description_description
      end
    end
  end
end
