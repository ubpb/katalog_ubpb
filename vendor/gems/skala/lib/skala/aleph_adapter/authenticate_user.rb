require_relative "../aleph_adapter"

module Skala
  class AlephAdapter::AuthenticateUser
    def initialize(adapter)
      @adapter = adapter
    end

    def call(user_id, password)
      @adapter.x_services.post(
        op: :"bor-auth",
        bor_id: user_id,
        library: @adapter.default_user_library,
        verification: password
      )
      .try do |_response|
        if  _response.include?("<z303>")
          true
        elsif  _response.include?("error")
          false
        else
          StandardError.new
        end
      end
    end
  end
end
