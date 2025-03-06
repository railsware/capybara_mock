# frozen_string_literal: true

RSpec.describe CapybaraMock::Stub, type: 'none' do
  context 'when default' do
    subject(:stub) do
      described_class.new(:get, 'http://example.com')
    end

    specify do
      expect(stub.call({})).to eq([200, {}, ''])
    end
  end

  context 'with regexp url' do
    subject(:stub) do
      described_class.new(:get, /example\.com/)
    end

    let(:request) do
      {
        method: 'GET',
        url: 'http://example.com',
        query: { 'foo' => 'bar' },
        headers: { 'FOO' => 'BAR' }
      }
    end

    specify do
      expect(stub.match?(request)).to be(true)
    end

    specify do
      expect(stub.match?(request.merge(url: 'http://www.example.com/'))).to be(true)
    end

    specify do
      expect(stub.match?(request.merge(url: 'https://example.com/'))).to be(true)
    end

    specify do
      expect(stub.match?(request.merge(url: 'http://sample.com/'))).to be(false)
    end

    specify do
      expect(stub.match?(request.merge(url: 'http://example.org/'))).to be(false)
    end
  end

  context 'with `.with`' do
    subject(:stub) do
      described_class.new(:get, 'http://example.com').with(
        query:,
        headers:,
        body:
      )
    end

    let(:query) { { 'foo' => 'bar' } }
    let(:headers) { { 'FOO' => 'BAR' } }
    let(:body) { nil }

    let(:request) do
      {
        method: 'GET',
        url: 'http://example.com',
        query:,
        headers:,
        body:
      }
    end

    specify do
      expect(stub.call({})).to eq([200, {}, ''])
    end

    specify do
      expect(stub.match?(request)).to be(true)
    end

    specify do
      expect(stub.match?(request.merge(method: 'POST'))).to be(false)
    end

    specify do
      expect(stub.match?(request.merge(url: 'http://sample.com'))).to be(false)
    end

    specify do
      expect(stub.match?(request.merge(query: {}))).to be(false)
    end

    specify do
      expect(stub.match?(request.merge(query: { 'foo' => 'xxx' }))).to be(false)
    end

    specify do
      expect(stub.match?(request.merge(query: { 'foo' => 'bar', 'any' => 'any' }))).to be(true)
    end

    specify do
      expect(stub.match?(request.merge(headers: {}))).to be(false)
    end

    specify do
      expect(stub.match?(request.merge(headers: { 'FOO' => 'XXX' }))).to be(false)
    end

    specify do
      expect(stub.match?(request.merge(headers: { 'FOO' => 'BAR', 'any' => 'any' }))).to be(true)
    end

    context 'when body nil' do
      specify do
        expect(stub.match?(request.merge(body: nil))).to be(true)
      end

      specify do
        expect(stub.match?(request.merge(body: 'SOME_BODY'))).to be(true)
      end
    end

    context 'when body given' do
      let(:body) { 'BODY' }

      context 'without content type' do
        specify do
          expect(stub.match?(request.merge(body: 'BODY'))).to be(true)
        end

        specify do
          expect(stub.match?(request.merge(body: nil))).to be(false)
        end

        specify do
          expect(stub.match?(request.merge(body: 'SOME_BODY'))).to be(false)
        end
      end

      context 'when content type application/x-www-form-urlencoded' do
        let(:headers) { { 'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8' } }
        let(:body) { Rack::Utils.build_nested_query({ 'a' => [1, 2], 'b' => [3, 4] }) }

        specify do
          expect(stub.match?(request.merge(body: Rack::Utils.build_nested_query(
            { 'a' => [1, 2], 'b' => [3, 4] }
          )))).to be(true)
        end

        specify do
          expect(stub.match?(request.merge(body: Rack::Utils.build_nested_query(
            { 'b' => [3, 4], 'a' => [1, 2] }
          )))).to be(true)
        end

        specify do
          expect(stub.match?(request.merge(body: Rack::Utils.build_nested_query(
            { 'a' => [3, 4], 'b' => [1, 2] }
          )))).to be(false)
        end
      end

      context 'when content type application/json' do
        let(:headers) { { 'Content-Type' => 'application/json; charset=UTF-8' } }
        let(:body) { JSON.dump({ 'a' => [1, 2], 'b' => [3, 4] }) }

        specify do
          expect(stub.match?(request.merge(body: JSON.dump(
            { 'a' => [1, 2], 'b' => [3, 4] }
          )))).to be(true)
        end

        specify do
          expect(stub.match?(request.merge(body: JSON.dump(
            { 'b' => [3, 4], 'a' => [1, 2] }
          )))).to be(true)
        end

        specify do
          expect(stub.match?(request.merge(body: JSON.dump(
            { 'a' => [3, 4], 'b' => [1, 2] }
          )))).to be(false)
        end
      end
    end
  end

  context 'with `.to_return`' do
    subject(:stub) do
      described_class.new(:get, 'http::/example.com').to_return(
        status: 400,
        headers: { 'Content-Type' => 'text/plain' },
        body: 'BODY'
      )
    end

    specify do
      expect(stub.call({})).to eq([400, { 'Content-Type' => 'text/plain' }, 'BODY'])
    end
  end

  context 'with `block`' do
    subject(:stub) do
      described_class.new(:get, 'http::/example.com').to_return do |**args|
        [201, { 'Content-Type' => 'OBJECT' }, args]
      end
    end

    let(:request) do
      {
        method: 'GET',
        url: 'http://example.com',
        query: { 'foo' => 'bar' },
        headers: { 'FOO' => 'BAR' }
      }
    end

    specify do
      expect(stub.call(request)).to eq([201, { 'Content-Type' => 'OBJECT' }, request])
    end
  end
end
