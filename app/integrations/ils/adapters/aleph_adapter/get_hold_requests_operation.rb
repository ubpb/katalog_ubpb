module Ils::Adapters
  class AlephAdapter
    class GetHoldRequestsOperation < Operation

      def call(user_id)
        response = adapter.rest_api.patron(user_id).circulationActions.requests.holds.get(
          view: :full
        )
        xml           = Nokogiri::XML(response)
        error_code    = xml.at_xpath("//reply-code")&.text
        error_message = xml.at_xpath("//reply-text")&.text

        if error_code == "0000"
          xml.xpath("//hold-request").map do |node|
            HoldRequestFactory.build(node)
          end.reject do |hold_request|
            # Entferne gelöschte Vormerkungen/Bereitstellungen.
            # Diese werden von Aleph auf ein Datum gesetz, welches in der Vergangenheit liegt.
            hold_request.end_hold_date && hold_request.end_hold_date < Date.today
          end
        else
          adapter.logger.error("GetHoldRequestsOperation failed! Error code: #{error_code}. Message: #{error_message}")
          []
        end
      end

    end
  end
end
