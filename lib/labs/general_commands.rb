require 'yaml'
require 'logger'
require 'terminal-table'

command :configure do |c|
	c.description = "Setup Labs API client configuration"

	c.option '--endpoint ENDPOINT', String, 'Microcloud endpoint URL'

	c.action do |args, options|
		options.default :endpoint => "http://api.eu-1-aws.10xlabs.net/"
		config_file = File.join(ENV['HOME'], Labs::CONFIG_FILE)

		if File.exists?(config_file)
			abort "Default configuration file exists: #{config_file}"
		else
			say "Running 'labs configure' for first time."
		end

		puts
		puts "You can get API credentials from http://manage.10xlabs.net/"
		puts

		auth_token = ask("API token: ")
		auth_secret = ask("API secret: ")

		puts
		puts "Identify registered SSH Key"
		puts

		default_key = ask("Alias of SSH Key to use: ") {|q| q.default = "default"}
		key_location = ask("Path to private-part of SSH Key (empty for ssh-agent only): ")

		unless key_location.empty?
			key_location = key_location.rchomp('"').chomp('"')
		else
			key_location = nil
		end

		if key_location && !File.exists?(key_location)
			abort "Unable to open #{key_location}"
		end

		puts "Using '#{options.endpoint}' as default endpoint."
		puts

		begin
			@client = Labs::APIClient.new(options.endpoint, auth_token, auth_secret)

			res = @client.get_ext("/ping")
			say "Credentials successfully verified." if res["status"] == "ok"

			config = {
				:endpoint => options.endpoint,
				:token => auth_token,
				:secret => auth_secret,
				:default_key => default_key
			}

			if key_location
				config[:keys] = {}
				config[:keys][default_key] = key_location
			end

			File.open(config_file, 'w') do |f|
				f.puts(YAML.dump(config))
			end

			say "Default configuration stored in #{config_file}."
		rescue => e
			say "Unable to configure Labs CLI: #{e.message}"
		end
	end
end

if $is_windows
	command :keygen do |c|
		c.description = "Run SSH Key generator"

		c.action do |args, options|
				require 'labs/win32/ssh_exec'

				Labs::Win32::keygen
		end
	end
end

command :status do |c|
	c.description = "Verify Labs API endpoint"

	c.action do |args, options|
		client = Labs::Config.instance.client
		status = client.get_ext("/ping")

		puts "ok" if status
	end
end

command :pools do |c|
	c.description = "List available Lab Pools"

	c.action do |args, options|
		client = Labs::Config.instance.client
		pools = client.get_ext("/pools")

		pools.each do |pool|
			puts pool["name"]
		end
	end
end

command :templates do |c|
	c.description = "List available machine templates"

	c.action do |args, options|
		client = Labs::Config.instance.client
		templates = client.get_ext("/templates")

		rows = []
		templates.each do |template|
			rows << [
				template["name"],
				template["version"],
				template["managed"] ? "YES": "n/a",
				template["description"],
				template["updated_at"]
			]
		end

		table = Terminal::Table.new :headings => ['Name', 'Version', 'Managed', 'description','Updated'], :rows => rows

		puts table
	end
end