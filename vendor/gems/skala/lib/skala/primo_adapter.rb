require "active_support"
require "active_support/core_ext"
require "skala/adapter"

class Skala::PrimoAdapter < Skala::Adapter
  require_relative "./primo_adapter/get_records"
  require_relative "./primo_adapter/search"
  require_relative "./primo_adapter/soap_api"

  attr_accessor :institution
  attr_accessor :enable_cdi
  attr_accessor :languages
  attr_accessor :locations
  attr_accessor :on_campus
  attr_accessor :soap_api_url
  attr_accessor :timeout

  def initialize(options = {})
    HashWithIndifferentAccess.new(options).try do |_options|
      self.institution  = _options[:institution]
      self.enable_cdi   = _options[:enable_cdi]
      self.languages    = _options[:languages]
      self.locations    = _options[:locations]
      self.on_campus    = _options[:on_campus]
      self.soap_api_url = _options[:soap_api_url]
      self.timeout      = _options[:timeout]
    end
  end

  #
  # internal api between adapter and operations
  #
  def soap_api
    self.class::SoapApi.new(self)
  end
end
