require 'logger'
require 'labs/api_client'

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

		client = Labs::Client.new("http://mc.default.labs.dev/",
			"a7b59762d8d7523f797b1ca83e33", 
			"0ec6bc855e719fc0638429c1fa04226fa7931f90ea6339af")

		status = client.post(:machine, nil, data)

		puts "Machine '#{status["name"]}' with UUID #{status["uuid"]} #{status["state"]}."
	end
end

command :list do |c|
	c.description = "list available VMs"

	# FIXME implement
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

	# FIXME implement
end