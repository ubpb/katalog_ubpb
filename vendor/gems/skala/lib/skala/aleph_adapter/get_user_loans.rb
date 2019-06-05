require "nokogiri"
require "skala/adapter/get_user_loans"
require_relative "./resolve_user"
require_relative "../aleph_adapter"

class Skala::AlephAdapter::GetUserLoans < Skala::Adapter::GetUserLoans
  include module_parent::ResolveUser

  def call(username, options = {})
    resolved_user_id = resolve_user(username)
    loans_type = options[:type] == :history ? :history : nil
    no_loans = options[:limit]
    aleph_options = { type: loans_type, view: :full, no_loans: no_loans }.compact
    raw_aleph_response = adapter.restful_api.patron(resolved_user_id).circulationActions.loans.get(aleph_options)

    if raw_aleph_response.include?("<error>")
      return nil
    else
      self.class::Result.new(
        loans: Nokogiri::XML(raw_aleph_response).xpath("//loan").map do |_loan|
          {
            id: id(_loan),
            due_date: due_date(_loan),
            fine: fine(_loan),
            loan_date: loan_date(_loan),
            record: {
              creator: creator(_loan),
              id: ill?(_loan) ? nil : ils_record_id(_loan),
              title: title(_loan),
              year_of_publication: year_of_publication(_loan)
            },
            renewable: renewable(_loan),
            returned_date: returned_date(_loan),
            signature: signature(_loan)
          }
        end,
        source: raw_aleph_response
      )
    end
  end

  private

  def creator(element)
    element.at_xpath(".//z13-author").try(:content).presence.try(:split, ";").try(:map, &:strip)
  end

  def id(loan)
    loan.attr("href")[/[^\/]+\Z/][/\A[^?]+/]
  end

  def due_date(loan)
    if _due_date = loan.at_xpath(".//z36-due-date|.//z36h-due-date").try(:content)
      Date.strptime(_due_date, "%Y%m%d")
    end
  end

  def loan_date(loan) # only available in full view
    if _loan_date = loan.at_xpath(".//z36-loan-date|.//z36h-loan-date").try(:content)
      Date.strptime(_loan_date, "%Y%m%d")
    end
  end

  def fine(loan)
    loan.at_xpath(".//fine").try(:content).presence.try(:to_f)
  end

  def ill?(element)
    element.at_xpath(".//z30-collection-code").try(:content) == "ILL" ||
    element.at_xpath(".//z36h-process-status").try(:content) == "IL"
  end

  def ils_record_id(element)
    element.at_xpath("./z13/z13-doc-number").try(:content).presence
  end

  def renewable(loan)
    z36_last_renew_date = loan.at_xpath("./z36/z36-last-renew-date").try(:content).presence

    # maybe its present but "00000000" or something else non valid
    last_renew_date = begin
      z36_last_renew_date.try do |_date|
        Date.strptime(_date, "%Y%m%d")
      end
    rescue ArgumentError
      nil
    end

    loan.attr("renew") == "Y" && (!last_renew_date || last_renew_date < Date.today)
  end

  def returned_date(loan)
    if _returned_date = loan.at_xpath(".//z36h-returned-date").try(:content)
      Date.strptime(_returned_date, "%Y%m%d")
    end
  end

  def title(element)
    element.at_xpath("./z13/z13-title").try(:content).presence
  end

  def signature(element)
    element.at_xpath("./z30/z30-call-no").try(:content).presence
  end

  def year_of_publication(element)
    element.at_xpath(".//z13-year").try(:content).presence
  end
end
