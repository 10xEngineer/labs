require 'logger'
require 'rbconfig'
require 'terminal-table'
require 'labs/utils/name'

command :create do |c|
	c.description = "create a new VM"

	c.option '--pool POOL', String, 'Use specified resource pool for new machine provisioning'
	c.option '--template TEMPLATE', String, 'Lab machine template to use'
	c.option '--size SIZE', Integer, 'Lab machine size (default 512 MB)'
	c.option '--name NAME', String, 'Use specific Lab Machine name'
	c.option '--key KEY', String, 'SSH Key name to use (as registered within management panel)'
	c.option '--http PORT', String, 'Setup HTTP forwarding to specified port'

	c.action do |args, options|
		options.default :pool => 'default'
		options.default :template => 'ubuntu-precise64'
		options.default :size => 512
		options.default :key => Labs::Config.instance.default_key || "default"
		options.default :http => nil

		data = {
			:pool => options.pool,
			:template => options.template,
			:size => options.size,
			:key => options.key,
			:name => options.name
		}

		data[:port_mapping] = {:http => options.http} if options.http

		res = Labs::Machines.create(data)

		puts "Machine '#{res["name"]}' #{res["state"]}."
	end
end

command :list do |c|
	c.description = "list available VMs"

	c.option '--uuid', 'Display extended machine list (with UUIDs)'

	c.action do |args, options|
		client = Labs::Config.instance.client

		machines = client.get(:machine, nil)

		unless machines.empty?
			rows = []
			machines.each do |machine|
				row = [
					machine["name"], 
					machine["state"]
				]

				row << machine["uuid"] if options.uuid

				row << machine["template"]
				row << machine["created_at"]

				rows << row
			end


			headers = ['Name', 'State']
			headers << 'UUID' if options.uuid
			headers << 'Template'
			headers << 'Created'

			table = Terminal::Table.new :headings => headers, :rows => rows

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

		Labs::MachinesLogic.ssh(name)
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

command :ps do |c|
	c.description = "Process status"

	c.action do |args, options|
		name = get_machine_name(args)

		client = Labs::Config.instance.client
		processes = client.get_ext("/machines/#{name}/processes")

		headers = ["USER", "PID", "%CPU", "%MEM", "VSZ", "RSS", "TIME", "COMMAND"]

		puts headers.join("\t")
		processes.each do |p|
			#puts process
			out = headers.map {|h| p[h.downcase]}.join("\t")

			puts out
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

			ssh_str = "ssh -A "
			ssh_str << "-p #{ssh_proxy["gateway"]["port"]} " if ssh_proxy["gateway"]["port"] != 22
			ssh_str << "#{ssh_proxy["proxy_user"]}@#{ssh_proxy["gateway"]["host"]}"

			fingerprint = ssh_proxy["fingerprint"]
		else
			ssh_str = "n/a"
			fingerprint = "n/a"
		end

		if machine["token"]
			endpoint = "#{machine["token"]}.#{machine["microcloud"]}"
		end

		mapping = machine["port_mapping"] || {}
		mappings = []
		mapping.keys.each do |serv|
			mappings << "#{serv}(#{mapping[serv]})"
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
		if endpoint
			rows << ['Endpoint', endpoint]
			rows << ['Service fwd', mappings.join(',')]
		end
		rows << ['Key fingerprint', fingerprint]
		rows << ['Created', machine["created_at"]]
		rows << ['Updated', machine["updated_at"]]

		table = Terminal::Table.new :headings => ['Key', 'Value'], :rows => rows
		puts table
	end
end

command :update do |c|
	c.description = "Update Machine properties"

	c.option '--http PORT', "Set http forwarding (0 to disable)"

	c.action do |args, options|
		options.default :http => nil
		name = get_machine_name(args)

		client = Labs::Config.instance.client
		machine = client.get(:machine, name)

		port_mapping = machine["port_mapping"] || {}

		if options.http
			if options.http == 0
				port_mapping.delete("http")
			else
				port_mapping["http"] = options.http
			end
		end

		data = {
			port_mapping: port_mapping
		}

		res = client.put_ext("/machines/#{name}", data)
	end
end

command :destroy do |c|
	c.description = "pernamently destroy a VM"

	c.option '--force', "Use the force to actually destroy the machine"

	c.action do |args, options|
		name = get_machine_name(args)

		if options.force
			res = Labs::Machines.destroy(name)

			puts "Machine '#{name}' destroyed."
		else
			puts "Not really destroyed. Use the force, Luke."
		end
	end	
end