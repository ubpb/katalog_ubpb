require "faraday/middleware"
require_relative "../../../aleph_api"

module AlephApi::Faraday
  module Response
    class EnforceUtf8EncodedBody < Faraday::Middleware
      def call(request_env)
        @app.call(request_env).on_complete do |_response_env|
         _response_env.body.force_encoding("utf-8")
        end
      end
    end
  end
end
