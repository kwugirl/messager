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
    it "fails if not from Mailgun" do
      post "/messages", MultiJson.encode({})
      expect(last_response.status).to eql(403)
    end

    it "succeeds if verified from Mailgun" do
      expect_any_instance_of(Endpoints::Messages).to receive(:verify_from_mailgun).and_return(true)
      post "/messages", MultiJson.encode({})

      expect(last_response.status).to eql(201)
    end
  end
end
