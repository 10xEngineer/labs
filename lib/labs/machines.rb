# encoding: utf-8
require 'labs/utils/cli'
require 'labs/utils/ssh'

module Labs
	class Machines
		def self.create(options)
			machine_size = options[:size]

			unless machine_size % 256 == 0 and machine_size >= 512
				raise Labs::CommandError, "Invalid machine size #{machine_size}MB. Specified size must be a multiple of 256 and >= 512"
			end

			options.delete(:name) if options[:name] && options[:name].empty?

			client = Labs::Config.instance.client
			client.post(:machine, nil, options)
		end

		def self.get(name)
			client = Labs::Config.instance.client
			client.get(:machine, name)
		end

		def self.destroy(name)
			client = Labs::Config.instance.client

			client.delete(:machine, name)
		end

	end

	class MachinesLogic
		def self.ssh(name)
			machine = Machines.get(name)
			abort "Machine not available." unless machine["state"] == "started"

			ssh_proxy = machine["ssh_proxy"]

			begin
				key = Labs::SSH.agent_key(ssh_proxy["fingerprint"])
			rescue Net::SSH::Authentication::AgentNotAvailable
				# On windows, Pageant is use explicitely
				unless $is_windows
					abort %Q{SSH Agent is not running.

	Please, run ssh-agent.

	For more information on how to get started with 10xEngineer Labs, visit
	http://help.10xengineer.me/categories/20068923-labs-documentation
					}
				end
			end

			unless key
				file_location = Labs::Config.instance.keys[Labs::Config.instance.default_key] || ""
				if $is_windows && !File.exists?(file_location)
					abort %Q{Registered SSH Key for machine is not configured in your .labs.rc or loaded in Pageant!

	For more information, visit
	http://help.10xengineer.me/categories/20068923-labs-documentation}
				elsif !$is_windows
					abort %Q{Registered SSH key not loaded in SSH Agent.

	Load the key into ssh-agent using

		% ssh-add path-to-registered-key

	For more information, visit
	http://help.10xengineer.me/categories/20068923-labs-documentation}
				end
			end

			if machine["ssh_proxy"]
				ssh_cmd = []
				ssh_cmd << "ssh -A"
				ssh_cmd << "-o LogLevel=ERROR"
				ssh_cmd << "-o UserKnownHostsFile=/dev/null"
				ssh_cmd << "-o StrictHostKeyChecking=no"			
				ssh_cmd << "-p #{ssh_proxy["gateway"]["port"]}" if ssh_proxy["gateway"]["port"] != 22
			 	ssh_cmd << "#{ssh_proxy["proxy_user"]}@#{ssh_proxy["gateway"]["host"]}"		 	

				command = ssh_cmd.join ' '		 	

				unless $is_windows
					exec command
				else
					require 'labs/win32/ssh_exec'

					Labs::Win32::win_ssh ssh_proxy["proxy_user"], ssh_proxy["gateway"]["host"], Labs::Config.instance.keys[Labs::Config.instance.default_key]
				end
			 else
				puts "No SSH proxy configured."
			end			
		end
	end
end
