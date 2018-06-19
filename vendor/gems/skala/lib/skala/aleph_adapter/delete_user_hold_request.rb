require "nokogiri"
require "skala/adapter/delete_user_hold_request"
require_relative "../aleph_adapter"
require_relative "./resolve_user"

class Skala::AlephAdapter::DeleteUserHoldRequest < Skala::Adapter::DeleteUserHoldRequest
  include parent::ResolveUser

  def call(username, hold_request_id, options = {})
    document_base = options[:document_base] || adapter.default_document_base
    record_id = "#{document_base}#{record_id}"
    resolved_user_id = resolve_user(username)

    raw_aleph_response = @adapter.restful_api.patron(resolved_user_id).circulationActions.requests.holds(hold_request_id).delete
    reply_code = Nokogiri::XML(raw_aleph_response).at_xpath("//reply-code").try(:content).try(:to_i)

    if reply_code == 0
      adapter.class::DeleteUserHoldRequest::Result.new(
        source: raw_aleph_response
      )
    else
      if reply_code == 8
        raise self.class::HoldRequestMissingError
      else
        raise adapter.class::RequestFailedError
      end
    end
  end
end
