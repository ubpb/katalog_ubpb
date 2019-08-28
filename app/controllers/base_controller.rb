# BaseController is the place to put code which should be
# shared between frontend and API controllers.
class BaseController < ActionController::Base
  # custom errors
  class MalformedSearchRequestError < StandardError; end

  def current_scope
    KatalogUbpb.config.find_scope(params[:scope]) ||
    KatalogUbpb.config.find_scope(params[:scope_id]) ||
    KatalogUbpb.config.find_scope(session[:scope_id]) ||
    KatalogUbpb.config.scopes.first
  end

  def current_user
    @current_user ||= begin
      # given api key has a higher precedence as the session
      if api_key = (request.headers["api-key"] || params[:api_key] || params[:access_token]) # request.headers[] always uses '-' notation
        GetUserService.call(api_key: api_key)
      elsif user_id = session["user_id"]
        GetUserService.call(id: user_id)
      end
    end
  end

  def search_request_from_params
    if params[:search_request]
      JSON.parse(params[:search_request]).try do |_deserialized_search_request|
        # try to set missing fields/values with reasonable defaults
        _deserialized_search_request.try(:[], "queries").each do |_query|
          if ["query_string"].include?(_query["type"])
            if _query.try(:[], "fields").blank? && (default_index_field = current_scope.try(:searchable_fields).try(:first))
              _query["fields"] = [default_index_field]
            end
          end
        end

        if _deserialized_search_request.try(:[], "sort").blank? && (default_sort_field = current_scope.try(:sortable_fields).try(:first))
          _deserialized_search_request["sort"] = [{field: default_sort_field}]
        end

        Skala::Adapter::Search::Request.new(_deserialized_search_request)
      end
    elsif params[:isbn]
      Skala::Adapter::Search::Request.new(
        queries: [{
          type: "query_string",
          query: params[:isbn],
          fields: ["isbn_search"]
        }]
      )
    elsif params[:issn]
      Skala::Adapter::Search::Request.new(
        queries: [{
          type: "query_string",
          query: params[:issn],
          fields: ["issn"]
        }]
      )
    elsif params[:oclc_id]
      Skala::Adapter::Search::Request.new(
        queries: [{
          type: "query_string",
          query: params[:oclc_id],
          fields: ["oclc_id"]
        }]
      )
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
  helper_method :on_campus?

end
