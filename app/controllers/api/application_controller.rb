class Api::ApplicationController < ApplicationController
  # Rails 4.2 does not support class level respond_to
  #respond_to :json

  rescue_from RuntimeError, :with => :handle_runtime_error

  protected

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
      #
      # Basic auth
      #
      if user_options = authenticate_with_http_basic { |u, p| Median::Aleph.authenticate(u, p) }
        user = User.find_or_create_by_ilsid(user_options[:ilsuserid]) { |u| u.update_attributes!(user_options) }
        session[:api_user_id] = user.id
      else
        request_http_basic_authentication
      end
    end
  end

  def current_user
    @current_api_user ||= User.find_by_id(session[:api_user_id]) if session[:api_user_id]
  end

  def handle_connection_error(exception)
    handle_error(exception)
  end

  def handle_runtime_error(exception)
    handle_error(exception)
  end

  def handle_error(exception)
    logger.error [exception, *exception.backtrace].join("\n")
    render json: {"error" => exception.message}, status: 500
  end

end
