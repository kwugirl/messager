require "spec_helper"

describe Endpoints::Messages do
  include Rack::Test::Methods

  def app
    Endpoints::Messages
  end

  describe "POST /messages" do
    describe "verifies came from Mailgun" do
      it "fails if not from Mailgun" do
        expect_any_instance_of(app).to receive(:verify_from_mailgun).and_return(false)
        post "/messages"

        expect(last_response.status).to eql(403)
      end

      it "succeeds if verified from Mailgun" do
        expect_any_instance_of(app).to receive(:verify_from_mailgun).and_return(true)
        post "/messages"

        expect(last_response.status).to eql(201)
      end
    end

    describe "forwards message" do
      before do
        allow_any_instance_of(app).to receive(:verify_from_mailgun).and_return(true)

        @params = {
          'recipient': 'some_org@example.com',
          'domain': 'example.com'
        }
      end

      it "extracts org name from message recipient address" do
        expect(HerokuAPIClient).to receive(:admin_emails_for).with('some_org').and_return([])

        post "/messages", @params
      end

      it "calls Mailgun messages API" do
        allow(HerokuAPIClient).to receive(:admin_emails_for).and_return(['admin@example.com'])

        message_partial = {to: 'admin@example.com'}
        expect(HTTParty).to receive(:post).with(app::MAILGUN_MESSAGES_ENDPOINT,
                                                basic_auth: app::MAILGUN_API_CREDENTIALS,
                                                body: hash_including(message_partial))

        post "/messages", @params
      end
    end
  end
end
