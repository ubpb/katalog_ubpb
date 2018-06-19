require "active_support"
require "active_support/core_ext"
require "elasticsearch"
require "skala/adapter"

class Skala::ElasticsearchAdapter < Skala::Adapter
  require_relative "elasticsearch_adapter/search"

  attr_accessor :hosts
  attr_accessor :index
  attr_accessor :timeout
  attr_accessor :type

  def hosts=(value)
    @hosts = value.try(:map) { |host| host.deep_symbolize_keys }
  end

  def initialize(options = {})
    HashWithIndifferentAccess.new(options).try do |_options|
      self.hosts   = _options[:hosts] || _options[:host] || _options[:urls] || _options[:url]
      self.index   = _options[:index]
      self.timeout = _options[:timeout]
      self.type    = _options[:type]
    end
  end

  #
  # internal api between adapter and operations
  #
  def elasticsearch_client
    Elasticsearch::Client.new hosts: @hosts, retry_on_failure: true
  end
end
