module Ils::Adapters
  class AlephAdapter
    class DeleteHoldRequestOperation < Operation

      def call(user_id, hold_request_id)
        response      = adapter.rest_api.patron(user_id).circulationActions.requests.holds(hold_request_id).delete
        xml           = Nokogiri::XML(response)
        error_code    = xml.at_xpath("//reply-code")&.text
        error_message = xml.at_xpath("//reply-text")&.text

        if error_code == "0000"
          true
        else
          adapter.logger.error("DeleteHoldRequestOperation failed! Error code: #{error_code}. Message: #{error_message}")
          false
        end
      end

    end
  end
end
