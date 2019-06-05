require "nokogiri"
require "skala/adapter/get_user_inter_library_loans"
require_relative "./resolve_user"
require_relative "../aleph_adapter"

class Skala::AlephAdapter::GetUserInterLibraryLoans < Skala::Adapter::GetUserInterLibraryLoans
  include module_parent::ResolveUser

  def call(username, options = {})
    resolved_user_id = resolve_user(username)
    raw_aleph_response = adapter.restful_api.patron(resolved_user_id).circulationActions.requests.ill.get(type: :active, view: :full)

    if raw_aleph_response.include?("<error>")
      return nil
    else
      self.class::Result.new(
        inter_library_loans: Nokogiri::XML(raw_aleph_response).xpath("//ill-request").map do |_ill_request|
          {
            due_date: due_date(_ill_request),
            id: id(_ill_request),
            order_id: order_id(_ill_request),
            pickup_location: pickup_location(_ill_request),
            record: {
              creator: creator(_ill_request),
              id: record_id(_ill_request),
              title: title(_ill_request),
              year_of_publication: year_of_publication(_ill_request)
            },
            status: status(_ill_request),
            update_date: update_date(_ill_request)
          }
        end,
        source: raw_aleph_response
      )
    end
  end

  private

  def order_id(element)
    element.at_xpath(".//z410-doc-number").try(:content)
  end

  def pickup_location(element)
    element.at_xpath(".//z410-pickup-location").try(:content)
  end


  # Mapping see: /exlibris/aleph/uXX_1/pad40/tab/pc_tab_exp_field.LNG
  def status(element)
    case element.at_xpath(".//z410-status").try(:content)
    when "Cancelled"                 then "CA"
    when "Closed"                    then "CLS"
    when "Closed"                    then "CLS"
    when "Conditional Reply"         then "CRP"
    when "Deleted"                   then "DEL"
    when "Damaged"                   then "DMG"
    when "Daemon Send Failed"        then "DSF"
    when "Error"                     then "ERR"
    when "Protocol Error"            then "ERR"
    when "Estimate Reply"            then "EST"
    when "Estimated Reply"           then "EST"
    when "Expired"                   then "EXP"
    when "Hold Placed"               then "HPL"
    when "Location Reply"            then "LCR"
    when "Location"                  then "LCR"
    when "Locate failed"             then "LOF"
    when "Loaned to Library"         then "LON"
    when "Loaned"                    then "LON"
    when "Loaned to Patron"          then "LOP"
    when "Locally Owned"             then "LOW"
    when "Locally owned"             then "LOW"
    when "Lost"                      then "LST"
    when "Ready for BL"              then "NEB"
    when "New - Staff Review"        then "NEM"
    when "New"                       then "NEW"
    when "No Time to Supply"         then "NTS"
    when "Overdue"                   then "OVD"
    when "Pending"                   then "PND"
    when "Recalled"                  then "RCL"
    when "Eingegangen zur Ausleihe"  then "RFL" # in .eng nicht enthalten ???
    when "Renew Accepted"            then "RNA"
    when "Renewal - Accepted"        then "RNA"
    when "Renew Rejected"            then "RNR"
    when "Renewal - Rejected"        then "RNR"
    when "Returned by Library"       then "RT"
    when "Returned"                  then "RT"
    when "Returned by Patron"        then "RTP"
    when "Retry"                     then "RTY"
    when "Shipped"                   then "SHP"
    when "Supplier Not Active"       then "SNA"
    when "Sent to Supplier"          then "SV"
    when "Unfilled"                  then "UNF"
    when "Waiting for Process"       then "WAP"
    when "Waiting Cancel Reply"      then "WCR"
    when "Waiting for Cancel Reply"  then "WCR"
    when "Waiting Patron Response"   then "WPR"
    when "Waiting for Renewal Reply" then "WRN"
    when "Waiting Renewal Reply"     then "WRN"
    when "Will be Supplied"          then "WSP"
    else
      "ZZZ"
    end
  end

  def creator(element)
    element.at_xpath(".//z13-author").try(:content).presence.try(:split, ";").try(:map, &:strip)
  end

  def update_date(element)
    if _date = element.at_xpath(".//z410-update-date").try(:content)
      Date.strptime(_date, "%Y%m%d")
    end
  end

  def id(element)
    element.attr("href")[/[^\/]+\Z/][/\A[^?]+/]
  end

  def due_date(element)
    if _due_date = element.at_xpath(".//z36-due-date|.//z36h-due-date").try(:content)
      Date.strptime(_due_date, "%Y%m%d")
    end
  end

  def record_id(element)
    element.at_xpath(".//z410-doc-number").try(:content).presence
  end

  def title(element)
    element.at_xpath(".//z13-title").try(:content).presence
  end

  def year_of_publication(element)
    element.at_xpath(".//z13-year").try(:content).presence
  end
end
