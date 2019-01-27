lib_directory = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH.unshift(lib_directory) unless
	$LOAD_PATH.include?(lib_directory) ||
	$LOAD_PATH.include?(File.expand_path(lib_directory))

require 'nessana/version'

Gem::Specification.new do |s|
	s.name = 'nessana'
	s.version = Nessana::VERSION
	s.summary = 'A Nessus dump parser and differ'
	s.description = <<-DESCRIPTION
A fast Nessus dump parser and differ.
DESCRIPTION
	s.authors = ['Kristofer Rye <kristofer.rye@gmail.com>']
	s.license = 'AGPL-3.0-only'
	s.homepage = 'https://github.com/rye/nessana'
	s.files = Dir.glob(['README.md', 'lib/**/*.rb', 'bin/**'])
	s.executables = 'nessana'

	s.add_dependency 'activerecord', '~> 5.2.2'
	s.add_dependency 'bulk_insert', '~> 1.7.0'
	s.add_dependency 'fastcsv', '~> 0.0.6'
	s.add_dependency 'mime-types', '~> 3.1'
	s.add_dependency 'sqlite3', '~> 1.3.13'
	s.add_dependency 'tty-spinner', '~> 0.9.0'

	s.add_development_dependency 'codecov', '~> 0.1.14'
	s.add_development_dependency 'guard', '~> 2.14'
	s.add_development_dependency 'guard-rspec', '~> 4.7'
	s.add_development_dependency 'pry', '~> 0.12.2'
	s.add_development_dependency 'rspec', '~> 3.7'
	s.add_development_dependency 'rubocop', '~> 0.57'
	s.add_development_dependency 'simplecov', '~> 0.16.1'

	s.required_ruby_version = '~> 2.4'
end
