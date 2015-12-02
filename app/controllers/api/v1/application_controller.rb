# In order to keep the API seperated from the frontend controllers and because authentication
# is handled slightly differently it does not inherit from ApplicationController.
class Api::V1::ApplicationController < ActionController::Base
  protect_from_forgery

  # This approach is chooses above using defaults: { format: "json" } in routing
  # file, because defaults: { format: ... } overwrites client content negotiation
  # using http accept requests header AND formats specified with ?format=...
  before_action do
    if request.format.to_s == "*/*"
      request.format = Mime::Type.lookup("application/json").ref
    end
  end

  # CSRF protection is only enforced for session based authentication
  skip_before_action :verify_authenticity_token, if: -> { params[:access_token].present? }

  def authenticate!
    if params[:access_token].present?
      #
      # Token auth (via URL)
      #
      user = User.find_by(api_key: params[:access_token])
      if user
        session[:api_user_id] = user.id
      else
        head :unauthorized
      end
    else
      head :unauthorized
    end
  end

  def current_user
    @current_api_user ||= User.find_by_id(session[:api_user_id]) if session[:api_user_id]
  end

  # def current_user_requested?
  #   current_user && params[:user_id].try(:to_i) == current_user.id
  # end
end
