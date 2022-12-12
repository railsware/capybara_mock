# frozen_string_literal: true

require 'capybara/cuprite'
require 'capybara/rspec'
require 'capybara_mock/rspec'

require_relative 'support/test_app'

Capybara.configure do |config|
  config.server = :webrick
  config.app = TestApp
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
