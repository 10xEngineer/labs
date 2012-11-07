# encoding: utf-8

module Labs
	module SpecHelper
		def all_files
			`git ls-files`.split($\)
		end

		def unix_files
			all_files.reject {|f| (f.match(/^assets\/.*/)) || (f.match(/win32/)) }
		end

		module_function :all_files
		module_function :unix_files
	end
end