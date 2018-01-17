class ApplicationController < BaseController
  include Breadcrumbs
  include JavascriptVariables

  protect_from_forgery

  # before filters
  before_action :set_title_addition
  before_action :set_robots_tag

  # Breadcrumb (always show homepage)
  before_action { add_breadcrumb name: "homepage#show", url: root_path }

  # helper methods
  helper_method :async_content_request?
  helper_method :current_action
  helper_method :current_locale
  helper_method :current_scope
  helper_method :current_user
  helper_method :global_message
  helper_method :current_path

  # rescues
  rescue_from MalformedSearchRequestError do
    redirect_to searches_path
  end

  def async_content_request?(identifier = nil)
    !!(request.xhr? && params.keys.include?("async_content") && (!identifier || params["async_content"] == identifier.to_s))
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

  def current_path
    query_params = request.query_parameters.dup

    if query_params[:search_request].blank? && @search_request.present? && @search_request.queries.any?{|q| q.query.present? }
      query_params[:search_request] = @search_request
    end

    "#{request.path}?#{query_params.to_param}"
  end

  def sanitize_return_path(return_path)
    if return_path.present?
      uri = URI(return_path)
      "#{uri.path}?#{uri.query}##{uri.fragment}"
    else
      nil
    end
  rescue
    nil
  end

  def current_locale
    session[:locale] || I18n.default_locale
  end

  def set_robots_tag
    response.headers["X-Robots-Tag"] = 'noindex,nofollow,noarchive,nosnippet,notranslate,noimageindex'
  end

  def global_message
    fn = File.join(Rails.root, 'config', 'GLOBAL_MESSAGE')
    @global_message ||= File.open(fn, 'r').read.html_safe if File.exists?(fn)
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
end
