require "faraday"
require_relative "./faraday/response/enforce_utf8_encoded_body"
require_relative "../aleph_api"

# if patron curl based http client is available, require it
begin require "patron"; rescue LoadError; end

class AlephApi::RestfulApiClient
  require_relative "./restful_api_client/patron"
  require_relative "./restful_api_client/record"

  RESTFUL_API_DEFAULT_PORT = 1891
  RESTFUL_API_DEFAULT_ROOT_PATH="/rest-dlf"
  RESTFUL_API_DEFAULT_SCHEME = "http"

  # don's use a constant here, because faraday treats them diffrently
  @@faraday_adapter = defined?(::Patron) ? :patron : ::Faraday.default_adapter

  attr_accessor :host
  attr_accessor :url

  def url
    @url || "#{RESTFUL_API_DEFAULT_SCHEME}://#{@host}:#{RESTFUL_API_DEFAULT_PORT}#{RESTFUL_API_DEFAULT_ROOT_PATH}"
  end

  def initialize(options = {})
    options.symbolize_keys.try do |_sanitized_options|
      @host = (_sanitized_options[:host] || ENV["ALEPH_RESTFUL_API_HOST"] || ENV["ALEPH_API_HOST"]).try(:strip)
      @url = (_sanitized_options[:url] || ENV["ALEPH_RESTFUL_API_URL"]).try(:strip)
    end
  end

  def patron(patron_id)
    Patron.new(self, patron_id)
  end

  def record(record_id)
    Record.new(self, record_id)
  end

  # inter-client api
  def http(method, path, options = {})
    # http://www.intridea.com/blog/2012/3/12/faraday-one-http-client-to-rule-them-all
    connection = ::Faraday.new do |_builder|
      _builder.request :url_encoded
      _builder.use AlephApi::Faraday::Response::EnforceUtf8EncodedBody
      _builder.adapter @@faraday_adapter
    end

    connection.send(method, "#{self.url}#{path}", options) do |_request|
      # some http libraries (e.g. patron) have tight connection timeouts which
      # may lead to (unnecessary) errors when used with aleph, so we raise 'em
      _request.options.open_timeout = 20 # seconds
    end
  end
end
