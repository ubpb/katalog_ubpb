require_relative "../circulation_actions"

class AlephApi::RestfulApiClient::Patron::CirculationActions::Cash
  def initialize(client, patron_id, cash_id = nil)
    @client = client
    @cash_id = cash_id
    @patron_id = patron_id
  end

  def get(options = {})
    if @cash_id
      @client.http(:get, "/patron/#{@patron_id}/circulationActions/cash/#{@cash_id}", options).try do |_response|
        _response.body
      end
    else
      @client.http(:get, "/patron/#{@patron_id}/circulationActions/cash", options).try do |_response|
        _response.body
      end
    end
  end
end
