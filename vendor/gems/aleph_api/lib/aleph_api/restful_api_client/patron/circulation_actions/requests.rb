require_relative "../circulation_actions"

class AlephApi::RestfulApiClient::Patron::CirculationActions::Requests
  require_relative "./requests/holds"
  require_relative "./requests/ill"

  def initialize(client, patron_id)
    @client = client
    @patron_id = patron_id
  end

  def get(options = {})
    @client.http(:get, "/patron/#{@patron_id}/circulationActions/requests", options).try do |_response|
      _response.body
    end
  end

  def holds(hold_id = nil)
    Holds.new(@client, @patron_id, hold_id)
  end

  def ill(ill_id = nil)
    ILL.new(@client, @patron_id, ill_id)
  end
end
