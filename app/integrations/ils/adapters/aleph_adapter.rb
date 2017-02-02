module Ils::Adapters
  class AlephAdapter < BaseAdapter
    include Contract

    attr_reader :x_api, :rest_api

    def initialize(options = {})
      super
      @x_api    = AlephApi::XServicesClient.new(url: options[:x_api_url])
      @rest_api = AlephApi::RestfulApiClient.new(url: options[:rest_api_url])
    end

  end
end
