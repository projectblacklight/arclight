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
require 'webdrivers'

Capybara.javascript_driver = :headless_chrome

Capybara.register_driver :headless_chrome do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--disable-gpu'
    opts.args << '--no-sandbox'
    opts.args << '--window-size=1280,1696'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.default_max_wait_time = 5 # our ajax responses are sometimes slow

Capybara.enable_aria_label = true

require 'arclight'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Pathname.new(File.expand_path('support/**/*.rb', __dir__))].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  config.infer_spec_type_from_file_location!

  config.include ViewComponent::TestHelpers, type: :component
  config.before(:each, type: :helper) { helper.extend ControllerLevelHelpers }
  config.before(:each, type: :view) { view.extend ControllerLevelHelpers }
end

# Provide a custom matcher that makes it easier to deal with pretty-printed
# XML

require 'rspec/expectations'

def condense_whitespace(str)
  str.squish.strip.gsub(/>[\n\s]+</, '><')
end

def equal_modulo_whitespace(string1, string2)
  condense_whitespace(string1) == condense_whitespace(string2)
end

RSpec::Matchers.define :eq_ignoring_whitespace do |expected|
  match do |actual|
    condense_whitespace(expected) == condense_whitespace(actual)
  end
end

RSpec::Matchers.define :include_ignoring_whitespace do |expected|
  ex = condense_whitespace(expected)
  match do |actual|
    actual.any? { |act| condense_whitespace(act) == ex }
  end
end

RSpec::Matchers.define :equal_array_ignoring_whitespace do |expected|
  match do |actual|
    actual.map { |act| condense_whitespace(act) } == expected.map { |ex| condense_whitespace(ex) }
  end
end
