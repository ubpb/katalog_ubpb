# BaseController is the place to put code which should be
# shared between frontend and API controllers.
class BaseController < ActionController::Base
  def current_scope
    KatalogUbpb.config.find_scope(params[:scope]) ||
    KatalogUbpb.config.find_scope(params[:scope_id]) ||
    KatalogUbpb.config.find_scope(session[:scope_id]) ||
    KatalogUbpb.config.scopes.first
  end

  def current_user
    @current_user ||= begin
      # given api key has a higher precedence as the session
      if api_key = (request.headers["api-key"] || params[:api_key]) # request.headers[] always uses '-' notation
        GetUserService.call(api_key: api_key)
      elsif user_id = session["user_id"]
        GetUserService.call(id: user_id)
      end
    end
  end

  def search_request_from_params
    if params[:search_request]
      JSON.parse(params[:search_request]).try do |_deserialized_search_request|
        Skala::Adapter::Search::Request.new(_deserialized_search_request)
      end
    end
  rescue
    raise MalformedSearchRequestError
  end

  def on_campus?(ip_address, allowed_ip_addresses_or_networks = current_scope.options.try(:[], "on_campus"))
    # http://stackoverflow.com/questions/3518365/rails-find-out-if-an-ip-is-within-a-range-of-ips
    [allowed_ip_addresses_or_networks].flatten.compact.any? do |_network_or_ip_address|
      IPAddr.new(_network_or_ip_address) === ip_address
    end
  end
end
