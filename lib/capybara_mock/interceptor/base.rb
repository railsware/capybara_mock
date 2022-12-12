# frozen_string_literal: true

module CapybaraMock
  module Interceptor
    # Base interceptor class
    class Base
      attr_reader :stubs, :unstubbed_requests

      def initialize
        @stubs = []
        @unstubbed_requests = []
      end

      private

      def stub_for(request)
        @stubs.find do |stub|
          stub.match?(request)
        end
      end
    end
  end
end
