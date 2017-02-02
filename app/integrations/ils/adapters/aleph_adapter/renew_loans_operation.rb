module Ils::Adapters
  class AlephAdapter
    class RenewLoansOperation < Operation

      def call(user_id)
        response      = adapter.rest_api.patron(user_id).circulationActions.loans.post
        xml           = Nokogiri::XML(response)
        error_code    = xml.at_xpath("//reply-code")&.text
        error_message = xml.at_xpath("//reply-text")&.text

        if error_code == "0000" || error_code == "0028"
          xml.xpath("//loan").map do |node|
            RenewLoanResultFactory.build(node)
          end
        else
          logger.error("RenewLoansOperation failed! Error code: #{error_code}. Message: #{error_message}")
          nil
        end
      end

    end
  end
end
