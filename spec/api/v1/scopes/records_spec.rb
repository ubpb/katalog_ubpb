require "rails_helper"

describe "GET /api/v1/scopes/:scope_id/records/:id" do
  let(:id) { "000973893" }

  it "returns the specified record" do
    get("/api/v1/scopes/test/records/#{id}", nil, {"HTTP_ACCEPT" => "*/*"})
    result = JSON.parse(response.body)
    expect(result).to be_present
    expect(result).to be_a(Hash)
  end

  context "if ?pretty=true" do
    it "returns a pretty printed result" do
      get("/api/v1/scopes/test/records/#{id}?pretty=true", nil, {"HTTP_ACCEPT" => "*/*"})
      expect(response.body).to start_with("{\n")
    end
  end
end


describe "/api/v1/scopes/:scope_id/records/:id_1,:id_2,...,:id_n" do
  let(:ids) { ["000857752", "000973893"] }

  it "returns the specified records" do
    get("/api/v1/scopes/test/records/#{ids.join(",")}", nil, {"HTTP_ACCEPT" => "*/*"})
    result = JSON.parse(response.body)
    expect(result).to be_present
    expect(result).to be_a(Array)
  end
end

