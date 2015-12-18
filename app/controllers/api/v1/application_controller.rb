class Api::V1::ApplicationController < BaseController
  protect_from_forgery

  # This approach is chooses above using defaults: { format: "json" } in routing
  # file, because defaults: { format: ... } overwrites client content negotiation
  # using http accept requests header AND formats specified with ?format=...
  before_action do
    if ["text/html", "*/*"].include?(request.format.to_s)
      request.format = Mime::Type.lookup("application/json").ref
    end
  end

  # CSRF protection is only enforced for session based authentication (bypassed if api_key is given)
  skip_before_action :verify_authenticity_token, if: -> { params[:api_key].present? }

  # http://www.vinaysahni.com/best-practices-for-a-pragmatic-restful-api#pretty-print-gzip
  after_action do
    if request.format.to_sym == :json && response.body.present?
      response.body = JSON.pretty_generate(JSON.parse(response.body))
    end
  end

  def authenticate!
    head :unauthorized unless current_user
  end

  def call_service(service, options = {})
    none_service_option_keys = [:on_failed, :on_invalid, :on_succeeded, :on_success, :on_unauthorized]
    service_options = options.reject do |_key, _|
      none_service_option_keys.include?(_key)
    end

    if can?(:call, operation = service.new(service_options))
      if operation.valid?
        if operation.call!.succeeded?
          if callback = options[:on_succeeded] || options[:on_success]
            callback.call(operation)
          else
            head :ok
          end
        else
          if callback = options[:on_failed]
            callback.call(operation)
          else
            head operation.errors[:http_status].first || :internal_server_error
          end
        end
      else
        if callback = options[:on_invalid]
          callback.call(operation)
        else
          head :bad_request
        end
      end
    else
      if callback = options[:on_unauthorized]
        callback.call(operation)
      else
        head :unauthorized
      end
    end
  end

  # def current_user_requested?
  #   current_user && params[:user_id].try(:to_i) == current_user.id
  # end
end
