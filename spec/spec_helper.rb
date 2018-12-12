# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
ENV['REPOSITORY_FILE'] ||= 'spec/fixtures/config/repositories.yml'

require 'simplecov'
SimpleCov.start do
  add_filter '/.internal_test_app/'
  add_filter '/spec/'
end

require 'engine_cart'
EngineCart.load_application!

require 'rspec/rails'

require 'selenium-webdriver'
Capybara.javascript_driver = :headless_chrome

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu no-sandbox] }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara.default_max_wait_time = 15 # our ajax responses are sometimes slow

require 'arclight'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
