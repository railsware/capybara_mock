# frozen_string_literal: true

require_relative 'lib/capybara_mock/version'

Gem::Specification.new do |spec|
  spec.name = 'capybara_mock'
  spec.version = CapybaraMock::VERSION
  spec.authors = ['Railsware Products Studio LLC']
  spec.email = ['support@mailtrap.io']

  spec.summary = 'CapybaraMock'
  spec.description = 'CapybaraMock'
  spec.homepage = 'https://github.com/railsware/capybara_mock'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/railsware/capybara_mock'
  spec.metadata['changelog_uri'] = 'https://github.com/railsware/capybara_mock/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rack', '>= 2.2.0'
end
