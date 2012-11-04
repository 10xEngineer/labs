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
		puts "You API credentials are available from http://manage.10xlabs.net/"
		puts

		auth_token = ask("API token: ")
		auth_secret = ask("API secret: ")

		puts

		puts "Using '#{options.endpoint}' as default endpoint."
		puts

		begin
			@client = Labs::APIClient.new(options.endpoint, auth_token, auth_secret)

			res = @client.get_ext("/ping")
			say "Credentials successfully verified." if res["status"] == "ok"

			config = {
				:endpoint => options.endpoint,
				:token => auth_token,
				:secret => auth_secret
			}

			File.open(config_file, 'w') do |f|
				f.puts(YAML.dump(config))
			end

			say "Default configuration stored in #{config_file}."
		rescue => e
			say "Unable to configure Labs CLI: #{e.message}"
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