require "rails_helper"

path = "/api/v1/scopes"

# GET
method = "get"

describe "#{method.upcase} #{path}" do
  before(:each) { send(method, path, nil, {"HTTP_ACCEPT" => "*/*"}) }

  context "if client does not specify accepted content types" do
    describe "Content-Type" do
      before(:each) { send(method, path, nil, {"HTTP_ACCEPT" => "*/*"}) }
      subject { response.content_type.to_s }

      it { is_expected.to eq("application/json") }
    end
  end

  it "returns the configured scopes" do
    result = JSON.parse(response.body)
    expect(result.length).to eq(Application.config.scopes.length)
  end
end
