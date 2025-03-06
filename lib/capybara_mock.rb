# frozen_string_literal: true

require_relative 'capybara_mock/version'
require_relative 'capybara_mock/stub'
require_relative 'capybara_mock/interceptor/base'
require_relative 'capybara_mock/interceptor/cuprite'

# ## CapybaraMock
#
# Mock capybara browser http requests.
#
# @example Stub external requests using `stub_request`
#
#   CapybaraMock
#     .stub_request(:get, 'http://example.com')
#     .to_return(status: 200, headers: {}, body: 'Hello')
#
# @example Stub internal requests using `stub_path``
#
#   CapybaraMock
#     .stub_path(:get, '/api/user/101')
#     .to_return(status: 200, headers: {}, body: 'Hello')
#
# @example More strict stub
#
#   CapybaraMock
#     .stub_request(:get, 'http://example.com')
#     .with(
#       query: {
#         token: '12345678'
#       },
#       headers: {
#         'Authorization' => 'Bearer 12345678',
#         'Content-Type' => 'application/json'
#       },
#       body: {
#         message: 'ping'
#       }.to_json
#     ).to_return(
#       status: 200,
#       headers: {
#         'Content-Type' => 'application/json'
#       },
#       body: {
#         message: 'pong'
#       }.to_json
#     )
#
# @example Dynamic stub based on actual request
#
#   CapybaraMock.stub_request(:get, /example/).to_return do |query:, **|
#     state = query['state']
#     [200, {'Location' => "http://localhost/foo?state={state}"}, '']
#   end
module CapybaraMock
  class Error < StandardError; end

  class << self
    # Stub capybara request for current session using path.
    #
    # @param method [String]
    # @param path [String]
    # @return [CapybaraMock::Stub]
    def stub_path(method, path, &)
      url = File.join(capybara_session.server.base_url, path)
      stub_request(method, url, &)
    end

    # Stub capybara request for current session using url.
    # It also initialize interceptor for current session on first stub.
    #
    # @param method [String]
    # @param url [String]
    # @return [CapybaraMock::Stub]
    def stub_request(method, url, &block)
      Stub.new(method, url, &block).tap do |stub|
        interceptor.stubs << stub
      end
    end

    # Remove capybara stub from current session.
    #
    # @param stub [CapybaraMock::Stub]
    def remove_stub(stub)
      interceptor.stubs.delete(stub)
    end

    # Clear all current session stubs
    def clear_stubs
      interceptor.stubs.clear
    end

    # Save unstubbed requests to path.
    def save_unstubbed_requests(path)
      return false unless @interceptor && @interceptor.unstubbed_requests.present?

      File.open(path, 'w') do |f|
        @interceptor.unstubbed_requests.each do |request|
          f.puts "#{request[:method]} #{request[:url]} #{request[:query]}"
          request[:headers].each do |k, v|
            f.puts "#{k}: #{v}"
          end
          f.puts request[:body]
          f.puts
        end
      end

      true
    end

    # Reset capybara mock interceptor.
    def reset!
      @interceptor = nil
    end

    private

    def interceptor
      @interceptor ||=
        case capybara_session.driver.class.name
        when 'Capybara::Cuprite::Driver'
          CapybaraMock::Interceptor::Cuprite.new(capybara_session)
        else
          raise "Capybara driver is not supported: #{capybara_session.driver.class}"
        end
    end

    def capybara_session
      Capybara.current_session
    end
  end
end
