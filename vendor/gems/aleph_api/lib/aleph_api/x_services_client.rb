require "faraday"
require_relative "../aleph_api"

class AlephApi::XServicesClient
  attr_accessor :host
  attr_accessor :url

  def url
    @url || (@host ? "#{@host}/X" : nil)
  end

  def initialize(options = {})
    options.symbolize_keys.try do |_sanitized_options|
      @host = (_sanitized_options[:host] || ENV["ALEPH_X_XSERVICES_HOST"] || ENV["ALEPH_API_HOST"]).try(:strip)
      @url = (_sanitized_options[:url] || ENV["ALEPH_X_SERVICES_URL"]).try(:strip)
    end
  end

  def get(params = {})
    Faraday.get(self.url, params).body
  end

  def post(params = {})
    Faraday.post(self.url, params).body
  end
end
