require "spec_helper"

describe Endpoints::Messages do
  include Rack::Test::Methods

  def app
    Endpoints::Messages
  end

  describe "POST /messages" do
    it "fails if not from Mailgun" do
      post "/messages"
      expect(last_response.status).to eql(403)
    end

    it "succeeds if verified from Mailgun" do
      expect_any_instance_of(app).to receive(:verify_from_mailgun).and_return(true)
      post "/messages"

      expect(last_response.status).to eql(201)
    end

    it "with a message recipient then calls HerokuAPIClient" do
      expect(HerokuAPIClient).to receive(:admin_emails_for).with('some_org')

      allow_any_instance_of(app).to receive(:verify_from_mailgun).and_return(true)
      post "/messages", {'recipient': 'some_org@example.com'}
    end
  end
end
