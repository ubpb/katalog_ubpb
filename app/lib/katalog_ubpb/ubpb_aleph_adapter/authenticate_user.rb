class KatalogUbpb::UbpbAlephAdapter::AuthenticateUser < Skala::AlephAdapter::AuthenticateUser

  def call(user_id, password)
    @adapter.x_services.post(
      op: :"bor-auth",
      bor_id: user_id,
      library: @adapter.default_user_library,
      verification: password
    ).try do |_response|
      if  _response.include?("<z303>")
        true
      elsif _response.include?("error")
        #error_log(_response)
        false
      else
        #error_log(_response)
        #StandardError.new
        false
      end
    end
  end

private

  def error_log(response)
    Rails.logger.error("AuthenticateUser failed! Response:\n#{response}")
  end

end
