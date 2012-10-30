require 'logger'
require 'terminal-table'

command :configure do |c|
	c.description = "Setup Labs client configuration"

	c.action do |args, options|
		raise 'not implemented'
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