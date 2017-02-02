module Ils::Adapters
  class AlmaAdapter < BaseAdapter
    include Ils::Contract

    attr_reader :api

    def initialize(options = {})
      super

      @api = AlmaApi.configure do |config|
        config.api_key        = options[:api_key]
        config.api_base_url   = options[:api_base_url]
        config.default_format = options[:default_format]
      end
    end

  end
end
