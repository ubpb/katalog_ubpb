module Ils::Adapters
  class AlephAdapter
    class GetFormerLoansOperation < Operation

      def call(user_id)
        response = adapter.rest_api.patron(user_id).circulationActions.loans.get(
          view: :full,
          no_loans: 100,
          type: :history
        )
        xml           = Nokogiri::XML(response)
        error_code    = xml.at_xpath("//reply-code")&.text
        error_message = xml.at_xpath("//reply-text")&.text

        if error_code == "0000"
          LoanFactory.build_loans(xml)
        else
          adapter.logger.error("GetFormerLoansOperation failed! Error code: #{error_code}. Message: #{error_message}")
          []
        end
      end

    end
  end
end
