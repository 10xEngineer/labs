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
				rows << [
					snapshot["name"],
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

command :destroy do |c|
	c.description = "destroy a snapshot"

	c.option '--name NAME', String, "Snapshot name"

	c.action do |args, options|
		options.default :name => nil

		name = get_machine_name(args)

		abort "Snapshot name missing" unless options.name

		client = Labs::Config.instance.client
		snapshot = client.delete_ext("/machines/#{name}/snapshots/#{options.name}")

		puts "Snapshot '#{options.name}' destroyed."
	end
end