class HerokuAPIClient
  class << self

    def admin_emails_for(org_name)
      response = members_endpoint(org_name)

      case response.code
      when 200
        members = JSON.parse(response.body)

        admin_emails = members.map do |member|
          member["email"] if member["role"] == "admin"
        end.compact
        puts "WARN: No admins amongst #{org_name} members" if admin_emails.empty?

        admin_emails
      when 404
        puts "WARN: Could not retrieve members for the org #{org_name}, likely invalid org"
        []
      else
        puts "WARN: Couldn't get members, got response code #{response.code} but maybe should retry?"
        []
      end
    end

    private

    def headers
      {
        'Accept' => 'application/vnd.heroku+json; version=3',
        'Authorization' => ENV['STUB_API_TOKEN'],
        'X-Heroku-Sudo' => 'true'
      }
    end

    def members_endpoint(org_name)
      endpoint = "https://organizations-api-stub.herokuapp.com/organizations/#{org_name}/members"
      HTTParty.get(endpoint, headers: headers)
    end
  end
end
