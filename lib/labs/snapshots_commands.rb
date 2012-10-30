require 'logger'
require 'action_view'
require 'terminal-table'

# FIXME get rid of action_view (actionpack)
include ActionView::Helpers::NumberHelper

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
		end
	end
end

command :diff do |c|
	c.description = "show changes between two snapshots"

	# FIXME implement
end

command :destroy do |c|
	c.description = "destroy a snapshot"

	# FIXME implement
end