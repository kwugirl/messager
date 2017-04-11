class HerokuAPIClient
  class << self

    def admin_emails_for(org_name)
      response = members_endpoint(org_name)

      case response.code
      when 200
        members = JSON.parse(response.body)
        members.map{ |member| member["email"] if member["role"] == "admin" }.compact
      when 404
        # invalid org, do some logging
        []
      else
        # do some logging
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
