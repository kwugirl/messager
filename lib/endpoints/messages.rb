module Endpoints
  class Messages < Base
    namespace "/messages" do
      # This endpoint is for Mailgun to notify us that it has received a
      # message using their Webhooks:
      # https://documentation.mailgun.com/user_manual.html#webhooks
      post do
        verify_from_mailgun(params['token'], params['timestamp'], params['signature'])

        status 201
      end
    end

    def verify_from_mailgun(token, timestamp, signature)
      api_key = ENV['MAILGUN_API_KEY']
      digest = OpenSSL::Digest::SHA256.new
      data = [timestamp, token].join
      halt 403 unless signature == OpenSSL::HMAC.hexdigest(digest, api_key, data)
    end
  end
end
