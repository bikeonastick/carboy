#
# This project is licensed under the Licensed under the Apache License, Version 2.0. 
# See LICENSE in this directory or http://www.apache.org/licenses/LICENSE-2.0 for a copy of the license.
#
# Copyright 2012 robert tomb (bikeonastick) 
#

lib = File.expand_path('../lib/', __FILE__) 
$:.unshift lib unless $:.include?(lib) 

Gem::Specification.new do |s| 
	s.name = "carboy" 
	s.license = "Apache License, Version 2.0" 
	s.version = "0.1.2"
	s.platform = Gem::Platform::RUBY 
	s.author = "robert tomb" 
	s.email = "bikeonastick@gmail.com" 
	s.homepage = "http://bikeonastick.blogspot.com/p/open-source-projects.html#carboy" 
	s.summary = "A gem to be used in rakefiles for simplified homebrew packaging."
	s.description = "When building homebrew formulae, there's a process needed to build and deliver them. Add this to your rakefile and you'll automatically get the standard rake targets needed to deliver. These targets expect a standard directory structure and two collections to drive the process."
	s.required_rubygems_version = ">= 1.3.5" 
	#s.add_dependency('foooo', '>= 1.2.1')
	s.files = Dir.glob("{lib}/**/*") + %w(LICENSE README ROADMAP) 
	s.require_path = 'lib' 
	s.rdoc_options << '--title' 
	s.rdoc_options << 'carboy: a tool for homebrew formulae' 
	s.rdoc_options << '--main' 
	s.rdoc_options << 'README' 
	s.rdoc_options << '--line-numbers'
end
