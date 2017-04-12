module Endpoints
  class Messages < Base
    namespace "/messages" do
      # This endpoint is for Mailgun to notify us that it has received a
      # message using their Webhooks:
      # https://documentation.mailgun.com/user_manual.html#webhooks
      post do
        verify_from_mailgun(params['token'], params['timestamp'], params['signature'])

        recipient = params['recipient']
        if recipient
          org = recipient.gsub(/@.+$/, "")
          admin_emails = HerokuAPIClient.admin_emails_for(org)

          message = {
            from: params['from'],
            to: admin_emails.join(','),
            subject: "[#{org}] #{params['subject']}",
            text: params['body-plain'],
            html: params['body-html']
          }
          forward_message(message)
        end

        status 201
      end
    end

    def verify_from_mailgun(token, timestamp, signature)
      api_key = ENV['MAILGUN_API_KEY']
      digest = OpenSSL::Digest::SHA256.new
      data = [timestamp, token].join
      halt 403 unless signature == OpenSSL::HMAC.hexdigest(digest, api_key, data)
    end

    def forward_message(message)
      endpoint = "https://api.mailgun.net/v3/premiumrush-starter.herokai.com/messages"

      credentials = {
        username: 'api',
        password: ENV['MAILGUN_API_KEY']
      }

      HTTParty.post(endpoint, basic_auth: credentials, body: message)
    end
  end
end
