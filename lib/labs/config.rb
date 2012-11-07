# encoding: utf-8

require 'labs/utils/api_client'

module Labs
	class Config
		@@instance = nil

		attr_reader :client, :default_key

		def initialize(endpoint, token, secret, key)
			@client = Labs::APIClient.new(endpoint, token, secret)
			@default_key = key
		end

		def self.instance
			unless @@instance
				config_file =  File.join(ENV['HOME'], Labs::CONFIG_FILE)

				unless File.exists?(config_file)
					abort "No configuration avaliable. Run 'labs configure' first."
				end

				config = YAML::load(File.open(config_file))

				unless config[:endpoint] && config[:token] && config[:secret]
					abort "Invalid configuration file."
				end

				@@instance = Config.new(config[:endpoint],
					config[:token],
					config[:secret],
					config[:default_key])
			end

			return @@instance
		end
	end
end