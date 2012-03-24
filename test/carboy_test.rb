require 'carboy'
require 'test/unit'

# 
# This project is licensed under the Licensed under the Apache License, Version 2.0. 
# See LICENSE in this directory or http://www.apache.org/licenses/LICENSE-2.0 for a copy of the license.
#
# Copyright 2012 robert tomb (bikeonastick) 
#
# Tests for project
#
class TestSimpleNumber < Test::Unit::TestCase

	def setup

	end

	def teardown
	end

	def test_initialize_without_name
		tst = Carboy.new()
		assert_equal('carboy',tst.name)
	end

	def test_initialize_with_name
		tstnm = 'foo'
		tst = Carboy.new() do |c|
			c.name = tstnm
		end
		assert_equal(tstnm,tst.name)
	end

	def test_initialize_with_brew
		tstbrew = 'foo'
		tst = Carboy.new() do |c|
			c.brew = tstbrew
		end
		assert_equal(tstbrew,tst.brew)
	end

	def test_is_repo_is_not_package
		tst = Carboy.new()
		tst.is_repo = false
		assert_equal(true, tst.is_package)
		tst.is_repo = true
		assert_equal(false, tst.is_package)
	end

	def test_is_package_is_not_repo
		tst = Carboy.new()
		tst.is_package = false
		assert_equal(true, tst.is_repo)
		tst.is_package = true
		assert_equal(false, tst.is_repo)
	end

end
