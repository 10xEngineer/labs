require 'logger'
require 'action_view'
require 'terminal-table'

# TODO validate snapshot name

# FIXME get rid of action_view (actionpack)
include ActionView::Helpers::NumberHelper

command :create do |c|
	c.description = "create new snapshot"

	c.option '--name NAME', String, "Snapshot name"

	c.action do |args, options|
		options.default :name => nil

		name = args.shift
		name = ENV["LAB_MACHINE"] unless name

		abort('Machine name required') unless name

		data = {}
		data["name"] = options.name if options.name

		client = Labs::Config.instance.client
		snapshot = client.post_ext("/machines/#{name}/snapshots", data)

		puts "Snapshot '#{snapshot['name']}' created."
	end
end

command :list do |c|
	c.description = "list available snapshots"

	c.action do |args, options|
		name = args.shift
		name = ENV["LAB_MACHINE"] unless name

		abort('Machine name required') unless name

		client = Labs::Config.instance.client

		snapshots = client.get_ext("/machines/#{name}/snapshots")

		unless snapshots.empty?
			rows = []

			snapshots.each do |snapshot|
				rows << [
					snapshot["name"],
					number_to_human_size(snapshot["used_size"]),
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

command :diff do |c|
	c.description = "show changes between two snapshots"

	# FIXME implement
end

command :destroy do |c|
	c.description = "destroy a snapshot"

	c.option '--name NAME', String, "Snapshot name"

	c.action do |args, options|
		options.default :name => nil

		name = args.shift
		name = ENV["LAB_MACHINE"] unless name

		abort('Machine name required') unless name

		abort "Snapshot name missing" unless options.name

		client = Labs::Config.instance.client
		snapshot = client.delete_ext("/machines/#{name}/snapshots/#{options.name}")

		puts "Snapshot '#{options.name}' destroyed."
	end
end