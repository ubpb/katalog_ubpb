require_relative "../requests"

class AlephApi::RestfulApiClient::Patron::CirculationActions::Requests::Holds
  def initialize(client, patron_id, hold_id = nil)
    @client = client
    @hold_id = hold_id
    @patron_id = patron_id
  end

  def get(options = {})
    if @hold_id
      @client.http(:get, "/patron/#{@patron_id}/circulationActions/requests/holds/#{@hold_id}", options).try do |_response|
        _response.body
      end
    else
      @client.http(:get, "/patron/#{@patron_id}/circulationActions/requests/holds", options).try do |_response|
        _response.body
      end
    end
  end

  def delete(options = {})
    if @hold_id
      @client.http(:delete, "/patron/#{@patron_id}/circulationActions/requests/holds/#{@hold_id}", options).try do |_response|
        _response.body
      end
    else
      raise ArgumentError, "No hold id given!"
    end
  end
end
