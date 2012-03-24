require 'rake'
require 'rake/tasklib'

#
# A ruby library of standard rake tasks for building and packaging Homebrew formulae. Find
# information on homebrew here: 
#
# * http://mxcl.github.com/homebrew/ 
#
# Find information on creating homebrew formulae:
#
# * https://github.com/adamv/homebrew-cookbook/tree/master/topics
# * https://github.com/mxcl/homebrew/wiki/Formula-Cookbook
#
# The idea for creating a library of rake tasks comes from here:
#
# * http://rake.rubyforge.org/classes/Rake/PackageTask.html#M000058
# 
# More documentation on Carboy here:
# * https://github.com/bikeonastick/Carboy
# * http://bikeonastick.blogspot.com/p/open-source-projects.html#carboy
# 
# Author:: robert tomb (mailto: bikeonastick@gmail.com)
# Copyright:: Copyright 2012 robert tomb (bikeonastick) 
# License:: This project is licensed under the Licensed under the Apache License, Version 2.0.  See LICENSE or http://www.apache.org/licenses/LICENSE-2.0 for a copy of the license.
#
class Carboy < Rake::TaskLib

	# the name of your project, which defaults to the name of the project directory (parent dir for the Rakefile) if not set
	attr_accessor :name
	# a way to override the Homebrew location for alternate installs
	attr_accessor :brew
	# Your project version, this is REQUIRED. Can be a string, date, or number sequence. It will be used in filenames. Use filename-safe chars.
	attr_accessor :version 
	# The url to where your test site is for installation, defaults to http://localhost/~<username>/
	attr_accessor	:test_url
	# The local directory path to your test site, defaults to ~/Sites
	attr_accessor :test_site_dir 
	# The production url for where your homebrew package will be accessed by other users.
	attr_accessor	:prod_url
	# Assuming you have filesystem access to your production site directory... DON'T USE, RESERVED FOR FUTURE USE.
	attr_accessor :prod_site_dir 
	# For future GIT repo support
	attr_accessor	:test_repo
	# For future GIT repo support
	attr_accessor :prod_repo
	# For future GIT repo support
	attr_accessor :repo_tag

	# For future GIT repo support
	attr_reader :is_repo
	# For future GIT repo support
	attr_reader :is_package
	# if, for some reason, you need to know where the cellar is...
	attr_reader :cellar

	# 
	# Allows you to call with a block (see examples) and set values. The only required value 
	# is @version, all others are set to resonable defaults.
	#
	def initialize()
		@is_repo = false
		@is_package = true
		@name = nil
		@brew = nil
		@version = nil

		yield self if block_given?

		usr =`whoami`.chomp 
		@test_site_dir = ( @test_site_dir == nil)? "/Users/#{usr}/Sites" : @test_site_dir
		@test_url = ( @test_url == nil)? "http://localhost/~#{usr}" : @test_url
		@brew = (@brew == nil)? '/usr/local' : @brew
		@cellar = (@cellar == nil)? "#{@brew}/Cellar" : @cellar
		@name = (name == nil) ? File.basename(Dir::pwd) : name
		@formula = @name
		unless @version == nil
			define()
		else
			raise "No version set, we can't do anything for you without it."
		end
	end

	# 
	# A vestige of an earlier idea. It's a lot like your appendix.
	#
	def init(name)
	end

	def is_repo=(isit)
		@is_repo = isit
		@is_package = !isit 
	end

	def is_package=(isit)
		@is_package = isit
		@is_repo = !isit
	end

	# 
	# The predefined tasks you get by instantiating the Carboy class in your Rakefile:
	# * hello: my first test task, it's rather quaint, so I kept it.
	# * package - delegates to assemble_formula
	# * prep - creates packaging and assemply directories
	# * clean - removes packaging directories
	# * stagefiles - copies files for packaging and does some variable substitution
	# * tarzip - tars and zips your file
	# * assemble_prod_formula - inserts prod_url into formula for download, does MD5 on package, injects that into formula
	# * assemble_formula - inserts test_url into formula for download, does MD5 on package, injects that into formula
	# * prep_test - puts the package file into your test_site_dir, and formula into homebrew's dir structure
	# * clean_test - removes package file from test_site_dir and the formula from homebrew
	# * clean_testfiles - cleans all known test files (even hidden homebrew caches)
	#
	def define
		desc "i say hello"
		task :hello do
			puts "hello #{@name} from #{__FILE__}"
			puts "where #{$0}"
			puts "here #{self}"
			puts "here #{Dir::pwd}"
			puts "here #{@name}"
		end

		desc "top level packaging task"
		task :package => [:assemble_formula] do
		end

		desc "Create packging and dist dirs"
		task :prep do
			mkdir "dist"
			mkdir_p "assemble/#{@formula}"
		end

		desc "Clean packaging and dist dirs"
		task :clean do
			if(File.exists?("dist"))
				rm_r "dist"
			end
			if(File.exists?("assemble"))
				rm_r "assemble"
			end
		end

		desc "Copies files to packaging dir and injects version"
		task :stagefiles => [:prep] do
			fn = "mydev"
			toSub = {"@NAME@" => @name, "@CELLAR@" => @cellar, "@VER@" => @version, "@FORMULA@" => @formula}
			d = "assemble/#{@formula}/#{fn}"
			s = "bin/#{fn}"
			copyFileReplVars(s,d,toSub)
			copy("lib/mylib.rb","assemble/#{@formula}/mylib.rb")
			copy("man/#{fn}.1","assemble/#{@formula}/#{fn}.1")
		end

		desc "Tars and gzips file"
		task :tarzip => [:stagefiles] do
			tf_name = "../dist/#{@formula}-#{@version}.tar"
			cd "assemble"
			`tar -cvf #{tf_name} #{@formula}`
			cd ".."
			`gzip dist/#{tf_name}`
		end

		desc "Does md5, injects into install script, and copies to dist for PRODUCTION"
		task :assemble_prod_formula => [:tarzip] do
			md5 = `md5 -q dist/#{@formula}-#{@version}.tar.gz`
			checksum = md5.chomp
			fn = "#{@formula}.rb"
			to = "dist/#{fn}"
			from = "formula/#{fn}"
			toSub = {	"@CHECKSUM@" => checksum, 
								"@FORMULA@" => @formula, 
								"@VER@" => @version,
								"@URL@" => @prod_url 
			}
			copyFileReplVars(from,to,toSub)
		end

		desc "Does md5, injects into install script, and copies to dist for TEST"
		task :assemble_formula => [:tarzip] do
			md5 = `md5 -q dist/#{@formula}-#{@version}.tar.gz`
			checksum = md5.chomp
			fn = "#{@formula}.rb"
			to = "dist/#{fn}"
			from = "formula/#{fn}"
			toSub = {	"@CHECKSUM@" => checksum, 
								"@FORMULA@" => @formula, 
								"@VER@" => @version,
								"@URL@" => @test_url 
			}
			copyFileReplVars(from,to,toSub)
		end

		desc "Prepares files for test install: copies formula to /usr/local/Library/Formula and tarball to ~/Sites"
		task :prep_test => [:clean, :assemble_formula] do
			copy("dist/#{@formula}.rb","#{@brew}/Library/Formula/#{@formula}.rb")
			copy("dist/#{@formula}-#{@version}.tar.gz","#{@test_site_dir}")
		end

		desc "Removes package from website, brew uninstall formula, removes formula.rb"
		task :clean_test do
			out = `brew uninstall #{@formula}`
			puts out
			Rake::Task["clean_testfiles"].invoke
		end

		desc "Removes files without brew uninstall, cuz sometimes the install goes terribly wrong."
		task :clean_testfiles do
			begin
				rm "#{@brew}/Library/Formula/#{@formula}.rb"
			rescue
			end
			begin
				rm "#{@test_site_dir}/#{@formula}-#{@version}.tar.gz"
			rescue
			end
			begin
				usr = `whoami`.chomp
				rm "/Users/#{usr}/Library/Caches/Homebrew/#{@formula}-#{@version}.tar.gz"
			rescue
			end
			begin
				rm "/Library/Caches/Homebrew/#{@formula}-#{@version}.tar.gz"
			rescue
			end
		end


	end

	#
	# Copies a file from one location to another and replaces values in the file
	# based on the contents of the map. It just does a straight search for the key
	# and replaces it with the value.
	# 
	def copyFileReplVars(relPathFromFn,relPathToFn,submap)
		destination = File.new(relPathToFn, "w+")
		from = File.open(relPathFromFn)
		lines = from.readlines
		lines.each {|ln|
			submap.each_pair{|key,value|
				ln.gsub!(/#{key}/,value)
			}
			destination.puts ln
		}
		destination.close
		from.close
	end
end
