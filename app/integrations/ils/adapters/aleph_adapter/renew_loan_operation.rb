module Ils::Adapters
  class AlephAdapter
    class RenewLoanOperation < Operation

      def call(user_id, loan_id)
        response      = adapter.rest_api.patron(user_id).circulationActions.loans(loan_id).post
        xml           = Nokogiri::XML(response)
        error_code    = xml.at_xpath("//reply-code")&.text
        error_message = xml.at_xpath("//reply-text")&.text

        if error_code == "0000" || error_code == "0028"
          loan_node = xml.at_xpath("//loan")
          RenewLoanResultFactory.build(loan_node)
        else
          adapter.logger.error("RenewLoanOperation failed! Error code: #{error_code}. Message: #{error_message}")
          nil
        end
      end

    end
  end
end
