require 'logger'

require 'labs/api_client'

command :status do |c|
	c.description = "ping Labs API endpoint"

	c.action do |args, options|
		#http://mc.default.labs.dev/
		client = Labs::Client.new("http://localhost:8080/", 
			"a7b59762d8d7523f797b1ca83e33", 
			"0ec6bc855e719fc0638429c1fa04226fa7931f90ea6339af")

		status = client.get_ext("/ping")

		puts "ok" if status["pong"]
	end
end
