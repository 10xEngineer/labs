require 'logger'
require 'terminal-table'
require 'labs/utils/name'

# TODO validate snapshot name

command :list do |c|
	c.description = "list available snapshots"

	c.action do |args, options|
		name = get_machine_name(args, true)

		client = Labs::Config.instance.client

		if name
			url = "/machines/#{name}/snapshots"
		else
			url = "/snapshots"
		end

		snapshots = client.get_ext(url)

		unless snapshots.empty?
			rows = []

			snapshots.each do |snapshot|
				if snapshot["machine_name"]
					snapshot_name = "#{snapshot["machine_name"]}@#{snapshot["name"]}"
				else
					snapshot_name = snapshot["name"]
				end

				rows << [
					snapshot_name,
					snapshot["used_size"],
					snapshot["created_at"]
				]
			end

			table = Terminal::Table.new :headings => ['name', 'size', 'created'], :rows => rows

			puts table
		else
			puts "No snapshots found"
		end
	end
end

command :persist do |c|
	c.description = "Create persitent snapshot"

	c.option '--source NAME', String, "Snapshot name"

	c.action do |args, options|
		abort "Source required (machine@snapshot)" unless options.source

		name = get_machine_name(args)
		abort "Snapshot name missing" unless name

		regex = options.source.match /([a-z0-9\-]+)@([\w\-]{3,32})/
		abort "Invalid source name. Format is machine-name@snapshot_name" unless regex
		
		machine = regex.captures.first
		snapshot_name = regex.captures.last

		client = Labs::Config.instance.client
		snapshot = client.post_ext("/machines/#{machine}/snapshots/#{snapshot_name}/persist", {:name => name})

		puts "Snapshot persisted."
	end
end

command :destroy do |c|
	c.description = "destroy a snapshot"

	c.action do |args, options|
		options.default :name => nil

		name = get_machine_name(args)

		regex_instant = name.match /([a-z0-9\-]+)@([\w\-]{3,32})/
		regex_persistent = name.match /([\w\-]{3,32})/

		abort "Invalid snapshot name. Format is machine-name@snapshot_name or snapshotname for persistent snapshots" unless regex_instant || regex_persistent

		if regex_instant
			machine = regex_instant.captures.first
			snapshot_name = regex_instant.captures.last
		elsif regex_persistent
			snapshot_name = regex_persistent.captures.first
		end
			

		client = Labs::Config.instance.client
		if machine
			snapshot = client.delete_ext("/machines/#{machine}/snapshots/#{snapshot_name}")
		else
			snapshot = client.delete_ext("/snapshots/#{snapshot_name}")
		end

		puts "Snapshot '#{snapshot_name}' destroyed."
	end
end