require 'formula'

# 
# This project is licensed under the Licensed under the Apache License, Version 2.0. 
# See LICENSE in this directory or http://www.apache.org/licenses/LICENSE-2.0 for a copy of the license.
#
# Copyright 2012 robert tomb (bikeonastick) 
#
class MyTools < Formula
	url '@URL@/@FORMULA@-@VER@.tar.gz'
	version '@VER@'
	homepage '@URL@'
	md5 '@CHECKSUM@'

	def install
		bin.install "mydev"
		lib.install "mylib.rb"
		man1.install "mydev.1"

	end
end
