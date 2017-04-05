require "spec_helper"

describe Endpoints::Messages do
  include Rack::Test::Methods

  def app
    Endpoints::Messages
  end

  before do
    header "Content-Type", "application/json"
  end

  describe "POST /messages" do
    it "succeeds" do
      post "/messages", MultiJson.encode({})
      expect(last_response.status).to eql(201)
    end
  end
end
