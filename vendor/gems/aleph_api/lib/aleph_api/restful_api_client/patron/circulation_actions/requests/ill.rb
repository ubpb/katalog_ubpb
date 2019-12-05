require_relative "../requests"

class AlephApi::RestfulApiClient::Patron::CirculationActions::Requests::ILL
  def initialize(client, patron_id, ill_id = nil)
    @client = client
    @ill_id = ill_id
    @patron_id = patron_id
  end

  def get(options = {})
    if @ill_id
      @client.http(:get, "/patron/#{@patron_id}/circulationActions/requests/ill/#{@ill_id}", options).try do |_response|
        _response.body
      end
    else
      @client.http(:get, "/patron/#{@patron_id}/circulationActions/requests/ill", options).try do |_response|
        _response.body
      end
    end
  end
end
