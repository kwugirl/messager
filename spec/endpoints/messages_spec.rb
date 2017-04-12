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

    describe "checks against blacklists" do
      before do
        allow_any_instance_of(app).to receive(:verify_from_mailgun).and_return(true)
      end

      it "for sender domain" do
        post "/messages", {'domain': 'blacksheep.com'}

        expect(last_response.status).to eql(403)
      end

      it "for message subject" do
        post "/messages", {'subject': 'nope'}

        expect(last_response.status).to eql(403)
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
        response = double
        allow(response).to receive(:code).and_return(200)

        message_partial = {to: 'admin@example.com'}
        expect(HTTParty).to receive(:post).with(app::MAILGUN_MESSAGES_ENDPOINT,
                                                basic_auth: app::MAILGUN_API_CREDENTIALS,
                                                body: hash_including(message_partial))
                                          .and_return(response)

        post "/messages", @params
      end

      it "joins multiple admin emails with commas" do
        multiple_admins = ['admin1', 'admin2', 'admin3']
        allow(HerokuAPIClient).to receive(:admin_emails_for).and_return(multiple_admins)
        response = double
        allow(response).to receive(:code).and_return(200)

        message_partial = {to: 'admin1,admin2,admin3'}
        expect(HTTParty).to receive(:post).with(app::MAILGUN_MESSAGES_ENDPOINT,
                                                basic_auth: app::MAILGUN_API_CREDENTIALS,
                                                body: hash_including(message_partial))
                                          .and_return(response)

        post "/messages", @params
      end

      it "doesn't try to forward message with no admin emails" do
        allow(HerokuAPIClient).to receive(:admin_emails_for).and_return([])

        expect(HTTParty).to_not receive(:post)

        post "/messages", @params
      end
    end
  end
end
