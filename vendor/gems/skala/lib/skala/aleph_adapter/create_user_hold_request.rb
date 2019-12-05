require "nokogiri"
require "skala/adapter/create_user_hold_request"
require_relative "../aleph_adapter"
require_relative "./resolve_user"

class Skala::AlephAdapter::CreateUserHoldRequest < Skala::Adapter::CreateUserHoldRequest
  include module_parent::ResolveUser

  def call(username, document_number, options = {})
    get_record_items_result = adapter.get_record_items(document_number, {username: username})

    if first_holdable_item = get_record_items_result.items.find(&:hold_request_can_be_created)
      document_base = options[:document_base] || adapter.default_document_base
      patron_id = resolve_user(username)
      record_id = "#{document_base}#{document_number}"
      item_id   = first_holdable_item.id

      raw_aleph_response = create_hold_request(patron_id, record_id, item_id)

      reply_code = Nokogiri::XML(raw_aleph_response).at_xpath("//reply-code").try(:content).to_i

      if reply_code == 0
        adapter.class::CreateUserHoldRequest::Result.new(success: true)
      else
        raise adapter.class::RequestFailedError
      end
    else
      raise adapter.class::BadRequestError
    end
  end

private

  def create_hold_request(patron_id, record_id, item_id)
    url = "/patron/#{patron_id}/record/#{record_id}/items/#{item_id}/hold"

    data = [
      "post_xml=",
      "<hold-request-parameters>",
        "<pickup-location>#{pickup_location(url)}</pickup-location>",
        "<start-interest-date>#{Date.today.strftime('%Y%m%d')}</start-interest-date>",
        "<last-interest-date>#{(Date.today + 1.year).strftime('%Y%m%d')}</last-interest-date>",
        "<rush>N</rush>",
      "</hold-request-parameters>"
    ].join # !!! do not add linebreaks or something else or it will fail

    adapter.restful_api.http(:put, url, data).try(:body)
  end

  # Always selects the first pickup location
  def pickup_location(url)
    response = adapter.restful_api.http(:get, url).try(:body)
    Nokogiri::XML(response).at_xpath("//pickup-location").try(:attr, "code")
  end

end
