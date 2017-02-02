module Ils::Adapters
  class AlephAdapter
    class GetUserOperation < Operation

      def call(username)
        response = adapter.x_api.post(
          op: "bor-info",
          bor_id: username,
          library: adapter.options[:user_library],
          cash: "N",
          hold: "N",
          loans: "N"
        )

        xml = Nokogiri::XML(response)
        error_message = xml.at_xpath("//error")&.text

        unless error_message
          UserFactory.build(xml.at_xpath("//bor-info"))
        else
          adapter.logger.error("GetUser failed! Message: #{error_message}")
          nil
        end
      end

    end
  end
end
