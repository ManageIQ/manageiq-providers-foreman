if ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

Dir[Rails.root.join("spec/shared/**/*.rb")].each { |f| require f }
Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

require "manageiq-providers-foreman"

VCR.configure do |config|
  config.ignore_hosts 'codeclimate.com' if ENV['CI']
  config.cassette_library_dir = File.join(ManageIQ::Providers::Foreman::Engine.root, 'spec/vcr_cassettes')

  secrets = Rails.application.secrets
  secrets.foreman.keys do |secret|
    config.define_cassette_placeholder(secrets.foreman_defaults[secret]) { secrets.foreman[secret] }
  end
end
