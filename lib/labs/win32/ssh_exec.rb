require 'win32ole'

module Labs
  module Win32

  	def win_ssh(user, host, key)
		putty_dir = File.expand_path('../../../../assets/', __FILE__)

		cmd = "\"#{key}\" -c \"#{putty_dir}/putty.exe\" -A #{user}@#{host}"

		puts cmd

		shell = WIN32OLE.new('Shell.Application')
		shell.ShellExecute('pageant.exe', cmd, putty_dir, 'open', 1)
  	end

  	module_function :win_ssh
  end
end
