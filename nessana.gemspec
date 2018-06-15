lib_directory = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH.unshift(lib_directory) unless
	$LOAD_PATH.include?(lib_directory) || $LOAD_PATH.include?(File.expand_path(lib_directory))

require 'nessana/version'

Gem::Specification.new do |s|
	s.name = 'nessana'
	s.version = Nessana::VERSION
	s.summary = "A Nessus dump parser and Asana task creator which does inference based on task statuses"
	s.authors = ['Kristofer Rye <kristofer.rye@gmail.com>']
	s.licenses = ['MIT']
	s.homepage = 'https://github.com/rye/nessana'
	s.files = Dir.glob(['README.md', 'lib/**/*.rb', 'bin/**'])
	s.executables = 'nessana'

	s.add_dependency 'asana', '~> 0.6.3'
	s.add_development_dependency 'guard', '~> 2.14'
	s.add_development_dependency 'guard-rspec', '~> 4.7'
	s.add_development_dependency 'rspec', '~> 3.7'
	s.add_development_dependency 'ruby-prof', '~> 0.17.0'
	s.add_development_dependency 'ruby-prof-flamegraph', '~> 0.3.0'
	s.add_development_dependency 'pry', '~> 0.11.3'
end
