# frozen_string_literal: true

require 'rack'
require 'json'

module CapybaraMock
  # Stub DSL
  class Stub
    def initialize(method, url)
      @method = method.to_s.upcase
      @url = url
      with
      to_return
    end

    def with(query: {}, headers: {}, body: nil)
      @query = query
      @headers = headers
      @body = body
      self
    end

    def to_return(status: 200, headers: {}, body: '', &block)
      @response = block || [status, headers, body]
      self
    end

    def call(request)
      if @response.respond_to?(:call)
        @response.call(**request)
      else
        @response
      end
    end

    def match?(request)
      match_method?(request) &&
        match_url?(request) &&
        match_query?(request) &&
        match_headers?(request) &&
        match_body?(request)
    end

    def match_method?(request)
      @method == request[:method]
    end

    def match_url?(request)
      if @url.is_a?(Regexp)
        @url.match?(request[:url])
      else
        @url == request[:url]
      end
    end

    def match_query?(request)
      @query == request[:query].slice(*@query.keys)
    end

    def match_headers?(request)
      @headers == request[:headers].slice(*@headers.keys)
    end

    def match_body?(request)
      return true unless @body

      decode_body(@body) == decode_body(request[:body])
    end

    private

    def decode_body(body)
      case @headers['Content-Type']
      when %r{application/x-www-form-urlencoded}
        Rack::Utils.parse_nested_query(body)
      when %r{application/json}
        JSON.parse(body)
      else
        body
      end
    end
  end
end
