require_relative "../ubpb_aleph_adapter"

module KatalogUbpb
  class UbpbAlephAdapter::GetUserFees
    def initialize(adapter)
      @adapter = adapter
    end

    def call(*args)
      @adapter.aleph_adapter.get_user_fees(*args).tap do |_get_user_fees_result|
        _get_user_fees_result.try(:[], "hits").try(:[], "hits").try(:each) do |_loan|
          _loan["fields"]["record_id"].try(:prepend, "PAD_ALEPH")
        end
      end
    end
  end
end
