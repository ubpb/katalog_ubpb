require_relative "../restful_api_client"

class AlephApi::RestfulApiClient::Record
  require_relative "./record/items"

  def initialize(client, record_id)
    @client = client
    @record_id = record_id
  end

  def get(options = {})
    @client.http(:get, "/record/#{@record_id}", options).try do |_response|
      _response.body
    end
  end

  def items(item_id = nil)
    Items.new(@client, @record_id, item_id)
  end
end
