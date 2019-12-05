require_relative "../circulation_actions"

class AlephApi::RestfulApiClient::Patron::CirculationActions::Loans
  def initialize(client, patron_id, loan_id = nil)
    @client = client
    @loan_id = loan_id
    @patron_id = patron_id
  end

  def get(options = {})
    @client.http(:get, url, options).try(:body)
  end

  def post(options = {})
    @client.http(:post, url, options).try(:body)
  end

  private

  def url
    "/patron/#{@patron_id}/circulationActions/loans/#{@loan_id}".sub(/\/\Z/, "")
  end
end
