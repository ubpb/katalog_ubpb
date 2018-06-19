require "active_support"
require "active_support/core_ext"
require "aleph_api"
require "skala/adapter"

class Skala::AlephAdapter < Skala::Adapter
  require_relative "aleph_adapter/authenticate_user"
  require_relative "aleph_adapter/create_user_hold_request"
  require_relative "aleph_adapter/delete_user_hold_request"
  #require_relative "aleph_adapter/get_record"
  require_relative "aleph_adapter/get_record_holdable_items"
  require_relative "aleph_adapter/get_record_items"
  require_relative "aleph_adapter/get_user"
  require_relative "aleph_adapter/get_user_former_loans"
  require_relative "aleph_adapter/get_user_hold_requests"
  require_relative "aleph_adapter/get_user_inter_library_loans"
  require_relative "aleph_adapter/get_user_loans"
  require_relative "aleph_adapter/get_user_transactions"
  require_relative "aleph_adapter/renew_user_loan"
  require_relative "aleph_adapter/renew_user_loans"
  require_relative "aleph_adapter/update_user"

  attr_accessor :default_document_base
  attr_accessor :default_user_library
  attr_accessor :restful_api_url
  attr_accessor :x_services_url

  def initialize(options = {})
    HashWithIndifferentAccess.new(options).try do |_options|
      self.default_document_base = _options[:default_document_base]
      self.default_user_library = _options[:default_user_library]
      self.restful_api_url = _options[:restful_api_url]
      self.x_services_url = _options[:x_services_url]
    end
  end

  #
  # apis used to implemented the operations
  #
  def restful_api
    @restful_api ||= AlephApi::RestfulApiClient.new(url: @restful_api_url)
  end

  def x_services
    @x_services ||= AlephApi::XServicesClient.new(url: @x_services_url)
  end
end
