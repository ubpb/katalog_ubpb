require_relative "../patron"

class AlephApi::RestfulApiClient::Patron::CirculationActions
  require_relative "./circulation_actions/cash"
  require_relative "./circulation_actions/loans"
  require_relative "./circulation_actions/requests"

  def initialize(client, patron_id)
    @client = client
    @patron_id = patron_id
  end

  def get(options = {})
    @client.http(:get, "/patron/#{@patron_id}/circulationActions", options).try do |_response|
      _response.body
    end
  end

  def cash(cash_id = nil)
    Cash.new(@client, @patron_id, cash_id)
  end

  def loans(loan_id = nil)
    Loans.new(@client, @patron_id, loan_id)
  end

  def requests
    Requests.new(@client, @patron_id)
  end
end
