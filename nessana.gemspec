Gem::Specification.new do |s|
	s.name = 'nessana'
	s.version = '0.1.0-alpha.0'
	s.summary = "A Nessus dump parser and Asana task creator which does inference based on task statuses"
	s.authors = ['Kristofer Rye <kristofer.rye@gmail.com>']
	s.licenses = ['MIT']
	s.homepage = 'https://github.com/rye/nessana'
	s.files = Dir.glob(['README.md', 'lib/**/*.rb', 'bin/**'])
	s.executables = 'nessana'

	s.add_dependency 'asana', '~> 0.6.3'
	s.add_development_dependency 'ruby-prof', '~> 0.17.0'
	s.add_development_dependency 'pry', '~> 0.11.3'
end
