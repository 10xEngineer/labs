require 'logger'
require 'terminal-table'
require 'labs/api_client'

command :configure do |c|
	c.description = "Setup Labs client configuration"

	c.action do |args, options|
		raise 'not implemented'
	end
end

command :status do |c|
	c.description = "Verify Labs API endpoint"

	c.action do |args, options|
		client = Labs::Client.new("http://mc.default.labs.dev/", 
			"a7b59762d8d7523f797b1ca83e33", 
			"0ec6bc855e719fc0638429c1fa04226fa7931f90ea6339af")

		status = client.get_ext("/ping")

		puts "ok" if status["pong"]
	end
end

command :pools do |c|
	c.description = "List available Lab Pools"

	c.action do |args, options|
		client = Labs::Client.new("http://mc.default.labs.dev/", 
			"a7b59762d8d7523f797b1ca83e33", 
			"0ec6bc855e719fc0638429c1fa04226fa7931f90ea6339af")

		pools = client.get_ext("/pools")

		pools.each do |pool|
			puts pool["name"]
		end
	end
end

command :templates do |c|
	c.description = "List available machine templates"

	c.action do |args, options|
		client = Labs::Client.new("http://mc.default.labs.dev/", 
			"a7b59762d8d7523f797b1ca83e33", 
			"0ec6bc855e719fc0638429c1fa04226fa7931f90ea6339af")

		templates = client.get_ext("/templates")

		rows = []
		templates.each do |template|
			rows << [
				template["name"],
				template["version"],
				template["managed"] ? "YES": "n/a",
				template["description"],
				template["meta"]["updated_at"]
			]
		end

		table = Terminal::Table.new :headings => ['Name', 'Version', 'Managed', 'description','Updated'], :rows => rows

		puts table
	end
end