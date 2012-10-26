# encoding: utf-8

require 'labs/utils/api_client'

module Labs
	class Config
		@@instance = nil

		attr_reader :client

		def initialize(endpoint, token, secret)
			@client = Labs::APIClient.new(endpoint, token, secret)
		end

		def self.instance
			unless @@instance
				# FIXME read config
				@@instance = Config.new("http://mc.default.labs.dev/",
				"a7b59762d8d7523f797b1ca83e33", 
				"0ec6bc855e719fc0638429c1fa04226fa7931f90ea6339af")
			end

			return @@instance
		end
	end
end