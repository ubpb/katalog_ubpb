module Ils::Adapters
  class AlephAdapter
    class AuthenticateUserOperation < Operation

      def call(username, password)
        adapter.x_api.post(
          op: "bor-auth",
          bor_id: username,
          library: adapter.options[:user_library],
          verification: password
        ).try do |response|
          if response.include?("<z303>")
            true
          elsif response.include?("error")
            log_error(response)
            false
          else
            log_error(response)
            false
          end
        end
      end

    private

      def log_error(response)
        adapter.logger.error("AuthenticateUser failed! Response:\n#{response}")
      end

    end
  end
end
