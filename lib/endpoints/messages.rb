module Endpoints
  class Messages < Base
    namespace "/messages" do
      # This endpoint is for Mailgun to notify us that it has received a
      # message using their Webhooks:
      # https://documentation.mailgun.com/user_manual.html#webhooks
      post do
        unless verify_from_mailgun(params['token'], params['timestamp'], params['signature'])
          logger.debug "Failed verification from mailgun"
          halt 403
        end

        forward_message(params)
        status 201
      end
    end

    def verify_from_mailgun(token, timestamp, signature)
      api_key = ENV['MAILGUN_API_KEY']
      digest = OpenSSL::Digest::SHA256.new
      data = [timestamp, token].join
      signature == OpenSSL::HMAC.hexdigest(digest, api_key, data)
    end

    MAILGUN_MESSAGES_ENDPOINT = "https://api.mailgun.net/v3/premiumrush-starter.herokai.com/messages"
    MAILGUN_API_CREDENTIALS = {
      username: 'api',
      password: ENV['MAILGUN_API_KEY']
    }

    def forward_message(params)
      message = construct_message(params)

      if message[:to] && !message[:to].empty?
        response = HTTParty.post(MAILGUN_MESSAGES_ENDPOINT, basic_auth: MAILGUN_API_CREDENTIALS, body: message)
        case response.code
        when 200
          logger.info "Successfully forwarded message from #{message[:from]} to #{message[:to]}"
          logger.info "Successfully forwarded message with subject #{message[:subject]}"
        else
          # some logging/error handling
          # figure out minimum required fields for posting a new message
        end
      end
    end

    def construct_message(params)
      # TODO: early return after verifying set of minimum needed params
      return {} unless params['recipient']

      org = extract_org_name(params['recipient'], params['domain'])
      admin_emails = HerokuAPIClient.admin_emails_for(org)

      {
        from: params['from'],
        to: admin_emails.join(','),
        subject: "[#{org}] #{params['subject']}",
        text: params['body-plain'],
        html: params['body-html']
      }
    end

    def extract_org_name(recipient, domain)
      recipient.gsub(/@#{domain}$/, "")
    end
  end
end
