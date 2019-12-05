require_relative "../restful_api_client"

class AlephApi::RestfulApiClient::Patron
  require_relative "./patron/circulation_actions"
  require_relative "./patron/record"

  def initialize(client, patron_id)
    @client = client
    @patron_id = patron_id
  end

  def get(options = {})
    @client.http(:get, "/patron/#{@patron_id}", options).try do |_response|
      _response.body
    end
  end

  def circulationActions
    CirculationActions.new(@client, @patron_id)
  end

  def record(record_id = nil)
    Record.new(@client, @patron_id, record_id)
  end
end
