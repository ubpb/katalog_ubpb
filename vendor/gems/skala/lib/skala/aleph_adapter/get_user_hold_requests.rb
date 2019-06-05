require "nokogiri"
require "skala/adapter/get_user_hold_requests"
require_relative "./resolve_user"
require_relative "../aleph_adapter"

class Skala::AlephAdapter::GetUserHoldRequests < Skala::Adapter::GetUserHoldRequests
  include module_parent::ResolveUser

  def call(username, options = {})
    resolved_user_id = resolve_user(username.upcase)

    raw_aleph_response = adapter.restful_api.patron(resolved_user_id).circulationActions.requests.holds.get(view: :full)

    if raw_aleph_response.include?("<error>")
      return nil
    else
      self.class::Result.new(
        hold_requests: Nokogiri::XML(raw_aleph_response).xpath("//hold-request").map do |_hold_request|
          {
            id: id(_hold_request),
            deleteable: deleteable?(_hold_request),
            place_in_queue: place_in_queue(_hold_request),
            creation_date: creation_date(_hold_request),
            begin_request_date: begin_request_date(_hold_request),
            end_request_date: end_request_date(_hold_request),
            begin_hold_date: begin_hold_date(_hold_request),
            end_hold_date: end_hold_date(_hold_request),
            record: {
              id: record_id(_hold_request)
            },
            status: status(_hold_request),
            signature: signature(_hold_request)
          }
        end.reject do |_hold_request|
          # Entferne geloeschte/bereitgestellte Vormerkungen. Diese werden von Aleph auf ein Datum gesetz, welches in der Vergangenheit liegt.
          _hold_request[:end_hold_date] < Time.zone.today if _hold_request[:end_hold_date]
        end,
        source: raw_aleph_response
      )
    end
  end

  private

  def signature(hold_request)
    hold_request.at_xpath("./z30/z30-call-no").try(:content)
  end

  def id(hold_request)
    hold_request.attr("href")[/[^\/]+\Z/][/\A[^?]+/]
  end

  def creation_date(hold_request)
    if date = hold_request.at_xpath("./z37/z37-open-date").try(:content)
      Date.strptime(date, "%Y%m%d")
    end
  end

  def deleteable?(hold_request)
    hold_request.attr("delete") == "Y"
  end

  def place_in_queue(hold_request)
    hold_request.at_xpath(".//status").try(:content).presence.try(:[], /Waiting in position \d+/).try(:[], /\d+/).try(:to_i)
  end

  def record_id(hold_request)
    hold_request.at_xpath(".//z13-doc-number").try(:content)
  end

  def begin_request_date(hold_request)
    if date = hold_request.at_xpath(".//z37-request-date").try(:content).presence
      Date.strptime(date, "%Y%m%d")
    end
  rescue
    nil
  end

  def end_request_date(hold_request)
    if date = hold_request.at_xpath(".//z37-end-request-date").try(:content).presence
      Date.strptime(date, "%Y%m%d")
    end
  rescue
    nil
  end

  def begin_hold_date(hold_request)
    if date = hold_request.at_xpath(".//z37-hold-date").try(:content).presence
      Date.strptime(date, "%Y%m%d")
    end
  rescue
    nil
  end

  def end_hold_date(hold_request)
    if date = hold_request.at_xpath(".//z37-end-hold-date").try(:content).presence
      Date.strptime(date, "%Y%m%d")
    end
  rescue
    nil
  end

  def status(hold_request)
    case hold_request.at_xpath(".//z37-status").try(:content).presence.try(:upcase)
      when "WAITING IN QUEUE" then :requested
      when "S"                then :on_hold
      when "IN PROCESS"       then :in_process
    end
  end
end
