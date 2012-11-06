# encoding: utf-8

Labs::Commands.create_command "list" do
	group "Default"
	description "List all available Lab Machines"

	def process
		client = Labs::Config.instance.client
		machines = client.get(:machine, nil)

		output.puts machines
	end
end