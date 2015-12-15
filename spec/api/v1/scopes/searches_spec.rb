require "rails_helper"

path = "/api/v1/scopes/:scope_id/searches"
substituted_path = path.gsub(":scope_id", "test")

# GET
method = "get"

describe "#{method.upcase} #{path}?search_request=..." do
  let(:search_request) do
    {
      queries: [
        {
          type: "simple_query_string",
          default_operator: "AND",
          fields: ["_all"],
          query: "linux"
        }
      ],
      sort: [{ field: "_score" }]
    }
  end
 
  context "if no search_request was given" do
    it "returns :bad_request" do
      send(method, substituted_path, nil, {"HTTP_ACCEPT" => "*/*"})
      expect(response.status).to eq(400)
    end
  end

  it "returns a search result" do
    send(method, substituted_path, {search_request: search_request}, {"HTTP_ACCEPT" => "*/*"})
    result = JSON.parse(response.body)
    expect(result["hits"]).to be_present
  end
end
