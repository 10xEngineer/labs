# encoding: utf-8

def get_machine_name(args)
		name = args.shift
		unless name
			name = ENV["LAB_MACHINE"]

			say "debug: using lab machine '#{name}' from environment variable LAB_MACHINE\n\n" if name
		end

		abort('Machine name required') unless name

		return name
end