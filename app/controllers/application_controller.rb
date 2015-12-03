class ApplicationController < ActionController::Base
  include Breadcrumbs

  protect_from_forgery

  # before filters
  before_filter :set_title_addition
  before_filter :set_robots_tag
  before_filter :capture_return_path

  # helper methods
  helper_method :async_content_request?
  helper_method :current_action
  helper_method :current_locale
  helper_method :current_scope
  helper_method :current_user
  helper_method :global_message
  helper_method :return_path

  # rescues
  rescue_from ActionController::RedirectBackError do
    redirect_to root_path
  end

  rescue_from (MalformedSearchRequestError = Class.new(StandardError)) do
    redirect_to searches_path
  end

  def async_content_request?(identifier = nil)
    !!(request.xhr? && params.keys.include?("async_content") && (!identifier || params["async_content"] == identifier.to_s))
  end

  def capture_return_path
    session[:return_to] = params[:return_to] if params[:return_to].present?
  end

  def return_path
    session[:return_to]
  end

  def redirect_back_or_to(default_path)
    redirect_to(session.delete(:return_to) || default_path)
  end

  def set_title_addition(title_addition = nil)
    @title_addition = title_addition ? title_addition : I18n.t("actions.#{current_action}")
  end

  def authenticate!
    redirect_to new_session_path unless current_user
  end

  # @Override
  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def current_action
    sanitized_controller_name = view_context.controller.class.to_s
    .underscore
    .gsub(/_?controller_?/, "")
    .gsub("/", ".")

    "#{sanitized_controller_name}##{view_context.controller.action_name}"
  end

  def current_locale
    session[:locale] || I18n.default_locale
  end

  def current_scope
    KatalogUbpb.config.find_scope(params[:scope]) || KatalogUbpb.config.find_scope(session[:scope_id]) || KatalogUbpb.config.scopes.first
  end

  def current_user
    @current_user ||= begin
      if user_id = session["user_id"]
        GetUserService.call(id: user_id)
      end
    end
  end

  def set_robots_tag
    response.headers["X-Robots-Tag"] = 'noindex,nofollow,noarchive,nosnippet,notranslate,noimageindex'
  end

  def global_message
    fn = File.join(Rails.root, 'config', 'GLOBAL_MESSAGE')
    @global_message ||= File.open(fn, 'r').read.html_safe if File.exists?(fn)
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

  def ip_addr_in_range?(low, high, addr)
    int_addr = numeric_ip(addr)
    int_addr <= numeric_ip(high) && int_addr >= numeric_ip(low)
  end

  def numeric_ip(ip_str)
    ip_str.split('.').inject(0) { |ip_num, part| ( ip_num << 8 ) + part.to_i }
  end

  def handle_connection_error(exception)
    logger.error [exception, *exception.backtrace].join("\n")
    flash[:error] = t('messages.connection_error')

    redirect_to searches_url
  end

  def on_campus?(ip_address, allowed_ip_addresses_or_networks = current_scope.options.try(:[], "on_campus"))
    # http://stackoverflow.com/questions/3518365/rails-find-out-if-an-ip-is-within-a-range-of-ips
    [allowed_ip_addresses_or_networks].flatten.compact.any? do |_network_or_ip_address|
      IPAddr.new(_network_or_ip_address) === ip_address
    end
  end

end
