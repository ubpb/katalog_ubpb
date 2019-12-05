require_relative "../patron"

class AlephApi::RestfulApiClient::Patron::Record
  require_relative "./record/holds"

  def initialize(client, patron_id, record_id)
    @client = client
    @patron_id = patron_id
    @record_id = record_id
  end

  def get(options = {})
    @client.http(:get, "/patron/#{@patron_id}/record/#{@record_id}", options).try do |_response|
      _response.body
    end
  end

  def holds(hold_group_id = nil)
    Holds.new(@client, @patron_id, @record_id, hold_group_id)
  end
end
