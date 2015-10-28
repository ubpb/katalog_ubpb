class ApplicationController < ActionController::Base
  include Breadcrumbs

  protect_from_forgery

  # before filters
  before_filter :set_title_addition
  before_filter :detect_browser
  before_filter :set_robots_tag
  before_filter :set_locale
  before_filter :search_only_mode

  # helper methods
  helper_method :current_action
  helper_method :current_locale
  helper_method :current_scope
  helper_method :current_user
  helper_method :global_message
  helper_method :skala_layout
  helper_method :random_id
  helper_method :search_only_mode

  # rescues
  rescue_from ActionController::RedirectBackError do
    redirect_to root_path
  end

  rescue_from (MalformedSearchRequestError = Class.new(StandardError)) do
    binding.pry
    redirect_to searches_path
  end

  def set_title_addition(title_addition = nil)
    @title_addition = title_addition ? title_addition : I18n.t("actions.#{current_action}")
  end

  def authenticate!
    if search_only_mode
      redirect_to root_url, notice: 'Diese Funktion ist auf Grund von Wartungsarbeiten zur Zeit deaktiviert.'
    else
      redirect_to new_session_path unless current_user
    end
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
    KatalogUbpb.config.find_search_scope(params[:scope]) || KatalogUbpb.config.find_search_scope(session[:scope_id]) || KatalogUbpb.config.search_scopes.first
  end

  def current_user
    @current_user ||= begin
      if user_id = session["user_id"]
        GetUserService.call(id: user_id)
      end
    end
  end

  def detect_browser
    request.variant =
    if browser.mobile?
      :phone
    else
      :desktop
    end
  end

  def set_robots_tag
    response.headers["X-Robots-Tag"] = 'noindex,nofollow,noarchive,nosnippet,notranslate,noimageindex'
  end

  def global_message
    fn = File.join(Rails.root, 'config', 'GLOBAL_MESSAGE')
    @global_message ||= File.open(fn, 'r').read.html_safe if File.exists?(fn)
  end

  def search_only_mode
    false
  end

  def search_request_from_params
    if params[:search_request]
      JSON.parse(params[:search_request]).try do |_deserialized_search_request|
        Skala::SearchRequest.new(_deserialized_search_request)
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

  def random_id(prefix = nil)
    "#{prefix}#{Random.rand(1000000)}"
  end

  def set_locale
    if params[:locale].present?
      session[:locale] = params[:locale]
    end

    I18n.locale = session[:locale] || I18n.default_locale
  end

  def handle_connection_error(exception)
    logger.error [exception, *exception.backtrace].join("\n")
    flash[:error] = t('messages.connection_error')

    redirect_to searches_url
  end
end
