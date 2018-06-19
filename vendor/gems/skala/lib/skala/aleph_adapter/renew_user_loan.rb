require "nokogiri"
require "skala/adapter/renew_user_loan"
require_relative "../aleph_adapter"
require_relative "./resolve_user"

class Skala::AlephAdapter::RenewUserLoan < Skala::Adapter::RenewUserLoan
  include parent::ResolveUser

  def call(username, loan_id, options = {})
    resolved_user_id = resolve_user(username)

    raw_aleph_response = adapter.restful_api.patron(resolved_user_id).circulationActions.loans(loan_id).post
    reply_code = Nokogiri::XML(raw_aleph_response).at_xpath("//reply-code").try(:content).try(:to_i)

    if reply_code == 0
      adapter.class::RenewUserLoan::Result.new(
        source: raw_aleph_response
      )
    else
      if reply_code == 28
        raise self.class::RenewFailedError
      else
        raise adapter.class::RequestFailedError
      end
    end
  end
end
