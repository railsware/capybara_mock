# frozen_string_literal: true

RSpec.describe 'CapybaraMock integration', driver: :cuprite, type: :feature do
  context 'when success responses' do
    context 'without stubs' do
      specify do
        visit('/ping')

        within('#ping_1') do
          expect(page).to have_text('ORIGINAL_PONG_1_1')
        end
        within('#ping_2') do
          expect(page).to have_text('ORIGINAL_PONG_2_2')
        end
      end
    end

    context 'with request url regexp stub' do
      specify do
        CapybaraMock.stub_request(:post, /api/).to_return do |url:, **|
          [200, {}, "MOCKED_PONG: #{url}"]
        end
        visit '/ping'
        within('#ping_1') do
          expect(page).to have_text("MOCKED_PONG: #{page.server.base_url}/api/ping")
        end
        within('#ping_2') do
          expect(page).to have_text("MOCKED_PONG: #{page.server.base_url}/api/ping")
        end
      end
    end

    context 'with path stub' do
      specify do
        CapybaraMock.stub_path(:post, '/api/ping').to_return(
          body: 'MOCKED_PONG_ALL'
        )
        visit '/ping'
        within('#ping_1') do
          expect(page).to have_text('MOCKED_PONG_ALL')
        end
        within('#ping_2') do
          expect(page).to have_text('MOCKED_PONG_ALL')
        end
      end
    end

    context 'with path query stubs' do
      specify do
        CapybaraMock.stub_path(:post, '/api/ping').with(
          query: { 'count' => '1' }
        ).to_return(
          body: 'MOCKED_PONG_1'
        )
        CapybaraMock.stub_path(:post, '/api/ping').with(
          query: { 'count' => '2' }
        ).to_return(
          body: 'MOCKED_PONG_2'
        )
        visit '/ping'
        within('#ping_1') do
          expect(page).to have_text('MOCKED_PONG_1')
        end
        within('#ping_2') do
          expect(page).to have_text('MOCKED_PONG_2')
        end
      end
    end

    context 'with path body stubs' do
      specify do
        CapybaraMock.stub_path(:post, '/api/ping').with(
          body: { count: 1 }.to_json
        ).to_return(
          body: 'MOCKED_PONG_1'
        )
        CapybaraMock.stub_path(:post, '/api/ping').with(
          body: { count: 2 }.to_json
        ).to_return(
          body: 'MOCKED_PONG_2'
        )
        visit '/ping'
        within('#ping_1') do
          expect(page).to have_text('MOCKED_PONG_1')
        end
        within('#ping_2') do
          expect(page).to have_text('MOCKED_PONG_2')
        end
      end
    end

    context 'with path query and body stubs' do
      specify do
        CapybaraMock.stub_path(:post, '/api/ping').with(
          query: { 'count' => '2' },
          body: { count: 2 }.to_json
        ).to_return(
          body: 'MOCKED_PONG_2_2'
        )
        visit '/ping'
        within('#ping_1') do
          expect(page).to have_text('ORIGINAL_PONG_1_1')
        end
        within('#ping_2') do
          expect(page).to have_text('MOCKED_PONG_2_2')
        end
      end
    end

    context 'with path block stub' do
      specify do
        CapybaraMock.stub_path(:post, '/api/ping').to_return do |query:, **|
          count = query['count']
          [200, {}, "MOCKED_PONG_#{count}"]
        end
        visit '/ping'
        within('#ping_1') do
          expect(page).to have_text('MOCKED_PONG_1')
        end
        within('#ping_2') do
          expect(page).to have_text('MOCKED_PONG_2')
        end
      end
    end

    context 'with stub removal' do
      specify do
        stub1 = CapybaraMock.stub_path(:post, '/api/ping').with(
          query: { 'count' => '1' }
        ).to_return(
          body: 'MOCKED_PONG_1'
        )
        stub2 = CapybaraMock.stub_path(:post, '/api/ping').with(
          query: { 'count' => '2' }
        ).to_return(
          body: 'MOCKED_PONG_2'
        )
        visit '/ping'
        within('#ping_1') do
          expect(page).to have_text('MOCKED_PONG_1')
        end
        within('#ping_2') do
          expect(page).to have_text('MOCKED_PONG_2')
        end

        CapybaraMock.remove_stub(stub1)
        visit '/ping'
        within('#ping_1') do
          expect(page).to have_text('ORIGINAL_PONG_1_1')
        end
        within('#ping_2') do
          expect(page).to have_text('MOCKED_PONG_2')
        end

        CapybaraMock.remove_stub(stub2)
        visit '/ping'
        within('#ping_1') do
          expect(page).to have_text('ORIGINAL_PONG_1_1')
        end
        within('#ping_2') do
          expect(page).to have_text('ORIGINAL_PONG_2_2')
        end
      end
    end

    context 'with clear stubs' do
      specify do
        CapybaraMock.stub_path(:post, '/api/ping').with(
          query: { 'count' => '1' }
        ).to_return(
          body: 'MOCKED_PONG_1'
        )
        CapybaraMock.stub_path(:post, '/api/ping').with(
          query: { 'count' => '2' }
        ).to_return(
          body: 'MOCKED_PONG_2'
        )
        visit '/ping'
        within('#ping_1') do
          expect(page).to have_text('MOCKED_PONG_1')
        end
        within('#ping_2') do
          expect(page).to have_text('MOCKED_PONG_2')
        end

        CapybaraMock.clear_stubs
        visit '/ping'
        within('#ping_1') do
          expect(page).to have_text('ORIGINAL_PONG_1_1')
        end
        within('#ping_2') do
          expect(page).to have_text('ORIGINAL_PONG_2_2')
        end
      end
    end
  end

  context 'when error responses' do
    context 'when no stubs' do
      specify do
        visit '/error'
        within('#loading') do
          expect(page).to have_content('Loaded')
        end
        within('#status') do
          expect(page).to have_text('422')
        end
        within('#body') do
          expect(page).to have_text('Something Required')
        end
      end
    end

    context 'when stub with 400' do
      specify do
        CapybaraMock.stub_path(:get, '/api/error').to_return(
          status: 400,
          body: 'Something Wrong'
        )
        visit '/error'
        within('#loading') do
          expect(page).to have_content('Loaded')
        end
        within('#status') do
          expect(page).to have_text('400')
        end
        within('#body') do
          expect(page).to have_text('Something Wrong')
        end
      end
    end

    context 'when stub with 401' do
      specify do
        CapybaraMock.stub_path(:get, '/api/error').to_return(
          status: 401,
          body: 'Something Wrong'
        )
        visit '/error'
        within('#loading') do
          expect(page).to have_content('Loaded')
        end
        within('#status') do
          expect(page).to have_text('401')
        end
        within('#body') do
          expect(page).to have_text('Something Wrong')
        end
      end
    end

    context 'when stub with 422' do
      specify do
        CapybaraMock.stub_path(:get, '/api/error').to_return(
          status: 422,
          body: 'Something Wrong'
        )
        visit '/error'
        within('#loading') do
          expect(page).to have_content('Loaded')
        end
        within('#status') do
          expect(page).to have_text('400')
        end
        within('#mock-status') do
          expect(page).to have_text('422')
        end
        within('#body') do
          expect(page).to have_text('Something Wrong')
        end
      end
    end
  end
end
