require_relative "../record"

class AlephApi::RestfulApiClient::Record::Items
  def initialize(client, record_id, item_id = nil)
    @client = client
    @item_id = item_id
    @record_id = record_id
  end

  def get(options = {})
    if @item_id
      @client.http(:get, "/record/#{@record_id}/items/#{@item_id}", options).try do |_response|
        _response.body
      end
    else
      @client.http(:get, "/record/#{@record_id}/items", options).try do |_response|
        _response.body
      end
    end
  end
end
