# frozen_string_literal: true

require 'capybara_mock'

RSpec.configure do |config|
  config.after(:each, type: :feature) do
    CapybaraMock.reset!
  end
end
