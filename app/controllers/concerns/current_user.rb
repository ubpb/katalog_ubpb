module CurrentUser
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  def current_user
    @current_user ||= begin
      user = begin
        # request.headers[] must use dash, no matter if header was provided with - or with _
        if api_key = (request.headers["api-key"] || params[:api_key])
          Skala::User.find_by_api_key(api_key)
        elsif user_id = session[:user_id]
          Skala::User.find_by_id(user_id)
        end
      end

      # FIXME: For performance reasons it is not a good idea
      # to query the ils on every request that uses current_user.
      # Lets find a proper cache strategy for this.
      if user.present?
        get_user = Skala::GetUserService.new({
          username: user.username
        }).call!

        if get_user.succeeded?
          user.tap do |object|
            object.assign_attributes(
              cash_balance: get_user.result["fields"]["fees"]["total_sum"],
              email_address: get_user.result["fields"]["contact_info"]["email"].first["email_address"],
              expiry_date: get_user.result["fields"]["expiry_date"],
              first_name: get_user.result["fields"]["first_name"].force_encoding("UTF-8"),
              last_name: get_user.result["fields"]["last_name"].force_encoding("UTF-8"),
              number_of_hold_requests: get_user.result["fields"]["holds"]["total_record_count"],
              number_of_loans: get_user.result["fields"]["loans"]["total_record_count"]
            )
          end
        end
      end
    end
  end
end
