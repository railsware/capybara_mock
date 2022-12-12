# frozen_string_literal: true

require 'uri'
require 'rack/utils'

module CapybaraMock
  module Interceptor
    # Cuprite interceptor
    class Cuprite < Base
      # @see https://github.com/chromium/chromium/blob/main/net/http/http_status_code_list.h
      SUPPORTED_STATUS_CODES = [
        100,
        101,
        103,
        *200..206,
        300,
        301,
        302,
        303,
        304,
        305,
        307,
        308,
        *400..418,
        425,
        429,
        *500..505
      ].freeze

      STATUS_CODE_HEADER_NAME = 'X-Mock-Response-Status'

      private

      def initialize(capybara_session)
        super()
        capybara_session.driver.browser.tap do |browser|
          browser.network.intercept
          browser.on(:request) { |request| call(request) }
        end
      end

      def call(cuprite_request)
        request = from_cuprite_request(cuprite_request)
        stub = stub_for(request)
        if stub
          response = stub.call(request)
          emulate_status_code!(response)
          cuprite_response = to_cuprite_response(response)
          cuprite_request.respond(**cuprite_response)
        else
          unstubbed_requests.push(request)
          cuprite_request.continue
        end
      rescue Exception => e # rubocop:disable Lint/RescueException
        warn e
        warn e.backtrace
        raise e
      end

      def from_cuprite_request(request)
        {
          method: request.method,
          url: URI(request.url).tap { |uri| uri.query = nil }.to_s,
          query: Rack::Utils.parse_query(URI(request.url).query),
          headers: request.headers,
          body: request.instance_variable_get(:@request)['postData']
        }
      end

      # Emulate status codes if it does not yet supported by CDP.
      # It uses more generic status code and pass actual status code in header.
      # Requires some client side middleware to finish emulation.
      #
      # @example
      #   [422, {}, 'BODY'] => [400, {'X-Mock-Response-Status' => 422}, 'BODY']
      #   [511, {}, 'BODY'] => [500, {'X-Mock-Response-Status' => 511}, 'BODY']
      def emulate_status_code!(response)
        status = response[0]
        return if SUPPORTED_STATUS_CODES.include?(status)

        response[0] = status.div(100) * 100
        response[1] = response[1].merge(STATUS_CODE_HEADER_NAME => status.to_s)
      end

      def to_cuprite_response(response)
        {
          responseCode: response[0],
          responseHeaders: response[1],
          body: response[2]
        }.compact
      end
    end
  end
end
