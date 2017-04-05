module Endpoints
  class Base < Sinatra::Base
    register Sinatra::Namespace

    set :dump_errors, true
    set :raise_errors, true
    set :show_exceptions, false

    configure :development do
      register Sinatra::Reloader
    end

    not_found do
      content_type :json
      status 404
      "{}"
    end
  end
end
