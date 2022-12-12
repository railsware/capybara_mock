[![test](https://github.com/railsware/capybara_mock/actions/workflows/main.yml/badge.svg)](https://github.com/railsware/capybara_mock/actions/workflows/main.yml)

# CapybaraMock

Library for stubbing HTTP requests in Capybara browser. 

## Features

* Stubbing interface similar to [WebMock](https://github.com/bblimke/webmock)
* Matching requests based on
  * method
  * url
  * query
  * headers
  * body

## Supported capybara drivers

* [Cuprite](https://github.com/rubycdp/cuprite)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add capybara_mock

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install capybara_mock

### RSpec

Add the following code to `spec/spec_helper`:

```ruby
require 'capybara_mock/rspec'
```

Then ensure your capybara use `:cuprite` driver for feature specs that you want to mock browser requests.

## Usage

* `Capybara.stub_request` - stub external request by full url or regexp.
* `Capybara.stub_path` - stub internal request (to your capybara application) by path.
* `Capybara.remove_stub` - remove previously added stub to current capybara session
* `Capybara.clear_stubs` - remove all stubs for current capybara session
* `Capybara.save_unstubbed_requests` - save unstubbed browser requests from current capybara session. Useful for debugging.

## Examples

### Stub external request

```ruby
CapybaraMock.stub_request(
  :get, 'https://api.stripe.com/v1/balance'
).to_return(
  status: 200,
  headers: {'Content-Type' => 'application/json'},
  body: {amount: 10100}.to_json
)
```

### Stub internal request

```ruby
CapybaraMock.stub_path(
  :get, '/api/users/me'
).to_return(
  status: 200,
  headers: {'Content-Type' => 'application/json'},
  body: {name: 'John Doe'}.to_json
)
```

### Stub with specific query

```ruby
CapybaraMock.stub_path(
  :get, '/api/users'
).with(
  query: {page: 1}
).to_return(
  status: 200,
  headers: {'Content-Type' => 'application/json'},
  body: [].to_json
)
```

### Stub with specific header

```ruby
CapybaraMock.stub_path(
  :get, '/api/users/1'
).with(
  headers: {
    'Authorization' => 'Bearer ACCESS_TOKEN'
  }
).to_return(
  status: 200,
  headers: {'Content-Type' => 'application/json'},
  body: {id: 1}.to_json
)
```

### Stub with specific body

```ruby
CapybaraMock.stub_path(
  :post, '/api/users'
).with(
  headers: {'Content-Type': 'application/x-www-form-urlencoded'}, 
  body: 'first_name=John&last_name=Doe'
).to_return(
  status: 200,
  headers: {'Content-Type' => 'application/json'},
  body: {id: 1}.to_json
)
```

```ruby
CapybaraMock.stub_path(
  :post, '/api/users'
).with(
  headers: {'Content-Type': 'application/json'}, 
  body: '{"first_name":"John","last_name":"Doe"}'
).to_return(
  status: 200,
  headers: {'Content-Type' => 'application/json'},
  body: {id: 1}.to_json
)
```

## Limitation

Unfortunately Chrome DevTools Protocol still does not support all valid http response codes.
Right now it [supports](https://github.com/chromium/chromium/blob/main/net/http/http_status_code_list.h) only:
* 100, 101, 103
* 200..206
* 300..305, 307..308
* 400..418, 425, 229
* 500..505

For unsupported codes cuprite interceptor will send basic code and real code in special response header `X-Mock-Response-Status`. So you you have to add interceptor for your http client.


### AXIOS interceptor

```js
axios.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.headers['x-mock-response-status']) {
      const status = parseInt(error.response.headers['x-mock-response-status'])
      error.message = `Request failed with status code ${status}`
      error.response.status = status
    }

   return Promise.reject(error)
 }
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/railsware/capybara_mock. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/railsware/capybara_mock/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CapybaraMock project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/railsware/capybara_mock/blob/master/CODE_OF_CONDUCT.md).
