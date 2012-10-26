require 'logger'
require 'terminal-table'

command :create do |c|
	c.description = "create a new VM"

	c.option '--pool POOL', String, 'Use specified resource pool for new machine provisioning'
	c.option '--template TEMPLATE', String, 'Lab machine template to use'
	c.option '--size SIZE', String, 'Lab machine size (default 512 MB)'
	c.option '--name NAME', String, 'Use specific Lab Machine name'

	c.action do |args, options| 
		options.default :pool => 'default'
		options.default :template => 'ubuntu-precise64'
		options.default :size => '512'

		machine_size = options.size.to_i
		unless machine_size % 256 == 0 and machine_size >= 512
			puts "Invalid machine size #{machine_size}MB. Specified size must be a multiple of 256 and >= 512" 
		end

		data = {
			:pool => options.pool,
			:template => options.template,
			:size => machine_size
		}

		data[:name] = options.name if options.name

		client = Labs::Config.instance.client

		status = client.post(:machine, nil, data)

		puts "Machine '#{status["name"]}' #{status["state"]}."
	end
end

command :list do |c|
	c.description = "list available VMs"

	c.action do |args, options|
		client = Labs::Config.instance.client

		machines = client.get(:machine, nil)

		unless machines.empty?
			rows = []
			machines.each do |machine|
				rows << [
					machine["name"], 
					machine["state"],
					machine["uuid"],
					machine["template"],
					machine["meta"]["created_at"]
				]
			end

			table = Terminal::Table.new :headings => ['Name', 'State', 'UUID','Template','Created'], :rows => rows

			puts table
		else
			say "No lab machines found"
		end
	end
end

command :ssh do |c|
	c.description = "open secure shell for a VM"
	
	# FIXME implement
end

command :snapshot do |c|
	c.description = "create a new VM snapshot"

	# FIXME implement
end

command :destroy do |c|
	c.description = "pernamently destroy a VM"

	c.option '--force', "Use the force to actually destroy the machine"

	c.action do |args, options|
		name = args.shift || abort('Machine name required')

		client = Labs::Config.instance.client
		if options.force
			res = client.delete(:machine, name)

			puts "Machine '#{name}' destroyed."
		else
			puts "Not really destroyed. Use the force, Luke."
		end
	end	
end