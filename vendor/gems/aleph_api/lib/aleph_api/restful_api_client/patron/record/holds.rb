require_relative "../circulation_actions"

class AlephApi::RestfulApiClient::Patron::Record::Holds
  def initialize(client, patron_id, record_id, hold_group_id = nil)
    @client = client
    @patron_id = patron_id
    @record_id = record_id
    @hold_group_id = hold_group_id
  end

  def get(options = {})
    @client.http(:get, url, options).try(:body)
  end

  def put(options = {})
    @client.http(:put, url, options).try(:body)
  end

  private

  def url
    "/patron/#{@patron_id}/record/#{@record_id}/holds/#{@hold_group_id}".sub(/\/\Z/, "")
  end
end
