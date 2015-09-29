# In order to keep the API seperated from the frontend controllers and because authentication
# is handled slightly differently it does not inherit from Skala::ApplicationController.
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
  skip_before_action :verify_authenticity_token, if: -> { params[:api_key].present? }

  # controllers which need authentification can use this as a before_action
  def authenticate!
    head :unauthorized unless current_user
  end

  def current_ability
    @current_ability ||= Skala::Ability.new(current_user)
  end

  def current_user
    @current_user ||=
    if api_key = (request.headers["api-key"] || params[:api_key]) # request.headers[] always uses '-' notation
      Skala::User.find_by_api_key(api_key)
    elsif user_id = session[:user_id]
      Skala::User.find_by_id(user_id)
    end
  end

  def current_user_requested?
    current_user && params[:user_id].try(:to_i) == current_user.id
  end
end
