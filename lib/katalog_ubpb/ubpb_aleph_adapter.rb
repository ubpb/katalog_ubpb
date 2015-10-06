require "skala/aleph_adapter"

module KatalogUbpb
  class UbpbAlephAdapter < Skala::Adapter
    require_relative "ubpb_aleph_adapter/get_record_items"
    require_relative "ubpb_aleph_adapter/get_user_fees"
    require_relative "ubpb_aleph_adapter/get_user_loans"
    require_relative "ubpb_aleph_adapter/get_user_requests"

    attr_accessor :aleph_adapter

    def self.locales
      @locales ||= Skala::AlephAdapter.locales.deep_merge(
        load_locales_from_directory("#{File.dirname(__FILE__)}/ubpb_aleph_adapter/locales")
      )
    end

    def initialize(*args)
      @aleph_adapter = Skala::AlephAdapter.new(*args)
    end

    def get_record_items(*args);  GetRecordItems.new(self).call(*args);  end
    def get_user_fees(*args);     GetUserFees.new(self).call(*args);     end
    def get_user_loans(*args);    GetUserLoans.new(self).call(*args);    end
    def get_user_requests(*args); GetUserRequests.new(self).call(*args); end

    #
    # try to delegate unhandled method calls to aleph adapter
    #
    def method_missing(method_name, *arguments, &block)
      if @aleph_adapter.respond_to?(method_name)
        @aleph_adapter.send(method_name, *arguments, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_all = false)
      @aleph_adapter.respond_to?(method_name, include_all) || super
    end

    def self.adjust_record_id(record_id)
      record_id.rjust(9, "0").prepend("PAD_ALEPH") unless record_id.nil?
    end
  end
end
