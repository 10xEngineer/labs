require 'logger'
require 'terminal-table'
require 'labs/utils/ssh'
require 'labs/utils/name'

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
					machine["created_at"]
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

	c.option '--identity IDENTITY', String, 'Select a file with the RSA/DSA key'

	c.action do |args, options|
		name = get_machine_name(args)

		# TODO raise hell if running on Windows
		client = Labs::Config.instance.client
		machine = client.get(:machine, name)

		ssh_proxy = machine["ssh_proxy"]

		unless options.identity || Labs::SSH.agent_key(ssh_proxy["fingerprint"])
			abort %Q{Unable to find SSH key required to access the lab machine.

Either load the keys into ssh-agent using

	% ssh-add path-to-registered-key

or specify it directly using option --identity

	% lab-machines ssh #{name} --identity path-to-registered-key

}
		end

		if machine["ssh_proxy"]
			ssh_cmd = []
			ssh_cmd << "ssh -A"
			ssh_cmd << "-o LogLevel=ERROR"
			ssh_cmd << "-o UserKnownHostsFile=/dev/null"
			ssh_cmd << "-o StrictHostKeyChecking=no"			
			ssh_cmd << "-p #{ssh_proxy["gateway"]["port"]}" if ssh_proxy["gateway"]["port"] != 22
			ssh_cmd << "-i #{options.identity}" if options.identity
		 	ssh_cmd << "#{ssh_proxy["proxy_user"]}@#{ssh_proxy["gateway"]["host"]}"		 	

			command = ssh_cmd.join ' '		 	

			exec command
		 else
			puts "No SSH proxy configured."
		end
	end
end

command :show do |c|
	c.description = "Show machine details"

	c.action do |args, options|
		name = get_machine_name(args)

		client = Labs::Config.instance.client
		machine = client.get(:machine, name)

		# TODO refactor ^^
		if machine["ssh_proxy"]
			ssh_proxy = machine["ssh_proxy"]

			ssh_str = "ssh "
			ssh_str << "-p #{ssh_proxy["gateway"]["port"]} " if ssh_proxy["gateway"]["port"] != 22
			ssh_str << "#{ssh_proxy["proxy_user"]}@#{ssh_proxy["gateway"]["host"]}"

			fingerprint = ssh_proxy["fingerprint"]
		else
			ssh_str = "n/a"
			fingerprint = "n/a"
		end


		rows = []

		rows << ['Name', machine["name"]]
		rows << ['UUID', machine["uuid"]]
		rows << ['State', machine["state"]]
		rows << ['Template', machine["template"]]
		# TODO
		rows << ['Snapshots', 1]
		rows << ['Total Storage', 'n/a']
		rows << ['SSH client',ssh_str]
		rows << ['Key fingerprint', fingerprint]
		rows << ['Created', machine["created_at"]]
		rows << ['Updated', machine["updated_at"]]

		table = Terminal::Table.new :headings => ['Key', 'Value'], :rows => rows
		puts table
	end
end

command :snapshot do |c|
	c.description = "create a new snapshot of the machine"

	# FIXME implement
end

command :destroy do |c|
	c.description = "pernamently destroy a VM"

	c.option '--force', "Use the force to actually destroy the machine"

	c.action do |args, options|
		name = get_machine_name(args)

		client = Labs::Config.instance.client
		if options.force
			res = client.delete(:machine, name)

			puts "Machine '#{name}' destroyed."
		else
			puts "Not really destroyed. Use the force, Luke."
		end
	end	
end