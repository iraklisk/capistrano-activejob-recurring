require "capistrano-activejob-recurring/version"

if defined?(Capistrano::VERSION) && Gem::Version.new(Capistrano::VERSION).release >= Gem::Version.new("3.0.0")
  load File.expand_path("../capistrano-activejob-recurring/tasks/capistrano-activejob-recurring.rake", __FILE__)
else
  require "capistrano-activejob-recurring/capistrano_integration"
end

