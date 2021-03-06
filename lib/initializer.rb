module Initializer
  def self.run
    $LOAD_PATH << "#{File.expand_path("../../lib", __FILE__)}"
    require_relative "../config/database"
    require "endpoints/base"
    require "endpoints/messages"
    require "heroku_api_client"
    require "routes"
  end
end

Initializer.run
