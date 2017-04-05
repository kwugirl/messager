ENV["RACK_ENV"] = "test"

require "bundler"
Bundler.require(:default, :test)

Dotenv.load

require_relative "../lib/initializer"

DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.before :all do
    load('db/seeds.rb') if File.exist?('db/seeds.rb')
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  config.color = true
  config.run_all_when_everything_filtered = true
  config.order = 'random'
end
