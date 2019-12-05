require "nokogiri"
require "skala/adapter/renew_user_loans"
require_relative "../aleph_adapter"
require_relative "./resolve_user"

class Skala::AlephAdapter::RenewUserLoans < Skala::Adapter::RenewUserLoans
  include module_parent::ResolveUser

  def call(username, loan_ids = nil, options = {})
    resolved_user_id = resolve_user(username)

    if loan_ids.blank? # renew all
      raw_aleph_response = adapter.restful_api.patron(resolved_user_id).circulationActions.loans.post
      successfully_renewed_loans_xpath = "//loan/status[contains(text(), 'success')]/parent::*"

      adapter.class::RenewUserLoans::Result.new(
        renewed_loans: begin
          Nokogiri::XML(raw_aleph_response).xpath(successfully_renewed_loans_xpath).map do |_loan|
            {
              id: _loan.attr("id"),
              due_date: new_due_date(_loan)
            }
          end
        end,
        source: raw_aleph_response
      )
    else
      raise "Unimplemented"
    end
  end

  private

  def new_due_date(loan)
    if date = loan.at_xpath("./new-due-date").try(:content)
      Date.strptime(date, "%Y%m%d")
    end
  end
end
