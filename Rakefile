require 'rubygems'
require 'rake/testtask'
require 'rake/clean'
#require 'rdoc/task'
require 'rake/rdoctask'
require 'rake/gempackagetask'

#
# This project is licensed under the Licensed under the Apache License, Version 2.0. 
# See LICENSE in this directory or http://www.apache.org/licenses/LICENSE-2.0 for a copy of the license.
#
# Copyright 2012 robert tomb (bikeonastick) 
#

gemspec = eval(File.read(Dir["*.gemspec"].first))

CLEAN.include('pkg','rdoc')

task :default => [:build]

desc "Validate the gemspec"
task :gemspec do
	  gemspec.validate
end

desc "Build gem locally"
task :build => [:clean, :prep, :gemspec, :rdoc, :package ]do
	#system "gem build #{gemspec.name}.gemspec"
	#FileUtils.mkdir_p "pkg"
	#FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", "pkg"
end

Rake::GemPackageTask.new(gemspec) do |pkg|
    pkg.need_tar = true
end

desc "Install gem locally"
task :install => :build do
	system "gem install pkg/#{gemspec.name}-#{gemspec.version}"
end

desc "uninstall local gem"
task :uninstall do
	system "gem uninstall #{gemspec.name} -v #{gemspec.version}"
end

desc "prepare directories"
task :prep do
	FileUtils.mkdir "pkg"
end

desc "generate documentation"
Rake::RDocTask.new do |rdoc|
		rdoc.rdoc_dir = 'rdoc'
		rdoc.main = "README"
		rdoc.rdoc_files.include("README", "LICENSE", "lib/**/*\.rb")
		rdoc.options << '--title' 
		rdoc.options << 'CaptchaMaker: for pure Ruby png-captchas' 
		rdoc.options << '--line-numbers'

end

Rake::TestTask.new('test') do |t|
	t.pattern = 'test/**/*_test.rb'
	t.warning = true
end
