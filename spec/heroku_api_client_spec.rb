require "spec_helper"

describe HerokuAPIClient do
  describe "admin_emails_for" do
    it "a valid organization returns emails of admin users" do
      response = double
      response_body = <<-eos
        [{\"email\":\"admin@example.com\", \"role\":\"admin\"},
         {\"email\":\"user@example.com\",  \"role\":\"member\"}]
        eos
      allow(response).to receive(:code).and_return(200)
      allow(response).to receive(:body).and_return(response_body)

      allow(HTTParty).to receive(:get).and_return(response)

      admin_emails = ["admin@example.com"]

      expect(HerokuAPIClient.admin_emails_for('valid_org')).to eql(admin_emails)
    end

    it "an invalid organization returns an empty array" do
      response = double
      allow(response).to receive(:code).and_return(404)

      allow(HTTParty).to receive(:get).and_return(response)

      expect(HerokuAPIClient.admin_emails_for('invalid_org')).to eql([])
    end
  end
end
