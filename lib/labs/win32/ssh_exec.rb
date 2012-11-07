require 'win32ole'

module Labs
  module Win32

  	def win_ssh(user, host)
		putty_dir = File.expand_path('../assets/', __FILE__)

		shell = WIN32OLE.new('Shell.Application')
		shell.ShellExecute('putty.exe', "-A #{user}@#{host}", putty_dir, 'open', 1)
  	end

  	module_function :win_ssh
  end
end
