require "nokogiri"
require "skala/adapter/get_user_transactions"
require_relative "../aleph_adapter"
require_relative "./resolve_user"

class Skala::AlephAdapter::GetUserTransactions < Skala::Adapter::GetUserTransactions
  include module_parent::ResolveUser

  def call(username, options = {})
    resolved_user_id = resolve_user(username)

    patron_cash_list = @adapter.restful_api.patron(resolved_user_id).circulationActions.cash.get(view: :full)
    patron_loan_list = @adapter.restful_api.patron(resolved_user_id).circulationActions.loans.get(view: :full)

    if [patron_cash_list, patron_loan_list].any? { |_response| _response.include?("<error>") }
      return nil
    else
      transactions = []

      # regular credits/debits
      Nokogiri::XML(patron_cash_list).xpath("//cash").each do |_cash|
        credit_or_debit = {
          id: id(_cash),
          creation_date: creation_date(_cash),
          record: {
            creator: creator(_cash),
            id: ill?(_cash) ? nil : record_id(_cash),
            title: title(_cash),
            year_of_publication: year_of_publication(_cash)
          },
          reason: reason(_cash),
          type: type(_cash),
          value: value(_cash),
          description: description(_cash),
          signature: signature(_cash)
        }

        transactions << credit_or_debit
      end

      # unentered debits from loans
      Nokogiri::XML(patron_loan_list).xpath("//loan").each do |_loan|
        if fine = _loan.at_xpath("./fine").try(:content).presence
          transactions << {
            id: nil,
            record: {
              id: ill?(_loan) ? nil : record_id(_loan),
              title: title(_loan)
            },
            reason: :overdue_fine,
            type: :debit,
            value: fine.to_f,
            signature: signature(_loan)
          }
        end
      end

      self.class::Result.new(
        transactions: transactions,
        source: [patron_cash_list, patron_loan_list]
      )
    end
  end

  private

  def creator(element)
    element.at_xpath(".//z13-author").try(:content).presence.try(:split, ";").try(:map, &:strip)
  end

  def creation_date(cash)
    if date = cash.at_xpath("./z31/z31-date").try(:content).presence
      Date.strptime(date, "%Y%m%d")
    end
  end

  def id(cash)
    cash.attr("href")[/[^\/]+\Z/][/\A[^?]+/]
  end

  def ill?(element)
    # For cash z30-collection-code is nil. This caused ubpb/issues#81.
    # We have no idea how to fix this. That meas for cash records you can't
    # identify ILL records.
    element.at_xpath(".//z30-collection-code").try(:content) == "ILL"
  end

  def record_id(element)
    element.at_xpath("./z13/z13-doc-number").try(:content).presence
  end

  def reason(cash)
    case cash.at_xpath("./z31/z31-type").try(:content).presence
      when /Kopierauftrag/ then :photocopy_request
      when /Überfällig/    then :overdue_fine
    end
  end

  def title(element)
    element.at_xpath("./z13/z13-title").try(:content).presence
  end

  def type(cash)
    case cash.attr("type")
      when "credit" then :credit
      when "debit"  then :debit
    end
  end

  def description(cash)
    cash.at_xpath("./z31/z31-description").try(:content).presence
  end

  def value(cash)
    cash.at_xpath("./z31/z31-sum").try(:content).try(:[], /\d+.\d+/).try(:to_f)
  end

  def year_of_publication(element)
    element.at_xpath(".//z13-year").try(:content).presence
  end

  def signature(element)
    element.at_xpath("./z30/z30-call-no").try(:content).presence
  end
end
