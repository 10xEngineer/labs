require 'logger'
require 'rbconfig'
require 'terminal-table'
require 'labs/utils/ssh'
require 'labs/utils/name'

command :create do |c|
	c.description = "create a new VM"

	c.option '--pool POOL', String, 'Use specified resource pool for new machine provisioning'
	c.option '--template TEMPLATE', String, 'Lab machine template to use'
	c.option '--size SIZE', String, 'Lab machine size (default 512 MB)'
	c.option '--name NAME', String, 'Use specific Lab Machine name'
	c.option '--key KEY', String, 'SSH Key name to use (as registered within management panel)'

	c.action do |args, options|
		options.default :pool => 'default'
		options.default :template => 'ubuntu-precise64'
		options.default :size => '512'
		options.default :key => Labs::Config.instance.default_key || "default"

		machine_size = options.size.to_i
		unless machine_size % 256 == 0 and machine_size >= 512
			puts "Invalid machine size #{machine_size}MB. Specified size must be a multiple of 256 and >= 512" 
		end

		data = {
			:pool => options.pool,
			:template => options.template,
			:size => machine_size,
			:key => options.key
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

	c.action do |args, options|
		name = get_machine_name(args)

		# TODO raise hell if running on Windows
		client = Labs::Config.instance.client
		machine = client.get(:machine, name)

		ssh_proxy = machine["ssh_proxy"]

		is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
		unless (is_windows || Labs::SSH.agent_key(ssh_proxy["fingerprint"]))
			abort %Q{Unable to find SSH key required to access the lab machine.

Load the key into ssh-agent using

	% ssh-add path-to-registered-key
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

command :snapshot do |c|
	c.description = "create new snapshot"

	c.option '--name NAME', String, "Snapshot name"

	c.action do |args, options|
		options.default :name => nil

		name = get_machine_name(args)

		data = {}
		data["name"] = options.name if options.name

		client = Labs::Config.instance.client
		snapshot = client.post_ext("/machines/#{name}/snapshots", data)

		puts "Snapshot '#{snapshot['name']}' created."
	end
end

command :revert do |c|
	c.description = "Revert machine to the most recent snapshot"

	c.option '--name NAME', String, "Snapshot name"	

	c.action do |args, options|
		options.default :name => "head"

		name = get_machine_name(args)

		client = Labs::Config.instance.client
		data = {
			:name => options.name
		}

		snapshot = client.put_ext("/machines/#{name}/snapshots", data)

		puts "Machine '#{name}' reverted to snapshot '#{snapshot["name"]}'"
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

			ssh_str = "ssh -A "
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
		rows << ['IPv4', machine["ipv4_address"]]
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