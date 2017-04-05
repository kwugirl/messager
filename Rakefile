require 'sequel/rake'
Sequel::Rake.load!

# Add your rake tasks to lib/tasks!
Dir["./lib/tasks/*.rake"].each { |task| load task }

task :env do
  require "bundler"
  Bundler.require
  require "./lib/initializer"
end

task :spec do
  require "rspec/core"
  code = RSpec::Core::Runner.run(
    ["./spec"],
    $stderr, $stdout)
  exit(code) unless code == 0
end

task :default => :spec
