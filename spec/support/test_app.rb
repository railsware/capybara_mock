# frozen_string_literal: true

TestApp = Rack::Builder.new do
  map '/ping' do
    run lambda { |_env|
      [
        200,
        {},
        [
          <<~HTML
            <html>
              <script>
                const updateDiv = async (id, url, data) => {
                  const response = await fetch(url, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(data)
                  })
                  const body = await response.text()
                  document.getElementById(id).textContent = body
                }
                const start = async () => {
                  await updateDiv('ping_1', '/api/ping?count=1', {count: 1})
                  await updateDiv('ping_2', '/api/ping?count=2', {count: 2})

                  document.getElementById('loading').textContent = 'Loaded'
                }
              </script>
              <body onLoad="start()">
                <div id="loading"></div>
                <div id="ping_1"></div>
                <div id="ping_2"></div>
              </body>
            </html>
          HTML
        ]
      ]
    }
  end

  map '/error' do
    run lambda { |_env|
      [
        200,
        {},
        [
          <<~HTML
            <html>
              <script>
                const start = async () => {
                  const response = await fetch('/api/error')
                  const status = response.status
                  const mockStatus = response.headers.get('x-mock-response-status')
                  const body = await response.text()

                  document.getElementById('status').textContent = status
                  document.getElementById('mock-status').textContent = mockStatus
                  document.getElementById('body').textContent = body
                  document.getElementById('loading').textContent = 'Loaded'
                }
              </script>
              <body onLoad="start()">
                <div id="loading"></div>
                <div id="status"></div>
                <div id="mock-status"></div>
                <div id="body"></div>
              </body>
            </html>
          HTML
        ]
      ]
    }
  end

  map '/api/ping' do
    run lambda { |env|
      get_count = Rack::Request.new(env).GET['count']
      post_count = JSON.parse(env['rack.input'].read)['count']
      [
        200,
        {},
        [
          "ORIGINAL_PONG_#{get_count}_#{post_count}"
        ]
      ]
    }
  end

  map '/api/error' do
    run lambda { |_env|
      [
        422,
        {},
        [
          'Something Required'
        ]
      ]
    }
  end
end.to_app
