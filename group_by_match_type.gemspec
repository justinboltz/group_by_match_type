# frozen_string_literal: true

require_relative 'lib/group_by_match_type/version'

Gem::Specification.new do |spec|
  spec.name = 'group_by_match_type'
  spec.version = GroupByMatchType::VERSION
  spec.authors = ['Your Name']
  spec.email = ['your.email@example.com']

  spec.summary = 'A gem for matching and grouping CSV records based on different criteria'
  spec.description = 'This gem processes CSV files and groups records that might represent the same person based on matching email addresses, phone numbers, or both'
  spec.homepage = 'https://github.com/yourusername/group_by_match_type'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[lib/**/*.rb exe/group_by_match_type README.md LICENSE.txt])
  spec.bindir = 'exe'
  spec.executables = ['group_by_match_type']
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'csv', '~> 3.0'

  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.21'
end
