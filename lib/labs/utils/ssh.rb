# encoding: utf-8

require 'net/ssh'
require 'sshkey'
module Labs
	module SSH
		def key_type(key)
			key_class = key.class.to_s
			"ssh-#{key_class.to_s.split('::').last.downcase}"
		end

		def ssh_public_key(key)
			type = key_type(key)
			data = [key.to_blob].pack('m0')

			"#{type} #{data}"
		end

		def agent_key(fingerprint)
			agent = Net::SSH::Authentication::Agent.connect

			identities = agent.identities

			identities.each do |identity|
				return true if SSHKey.fingerprint(ssh_public_key(identity)) == fingerprint
			end

			false
		end

		module_function :key_type
		module_function :ssh_public_key
		module_function :agent_key
	end
end