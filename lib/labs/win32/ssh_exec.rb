require 'win32ole'

module Labs
  module Win32

  	def win_ssh(user, host, key)
		putty_dir = File.expand_path('../../../../assets/', __FILE__)

		cmd = "\"#{key}\" -c \"#{putty_dir}/putty.exe\" -A #{user}@#{host}"

		shell = WIN32OLE.new('Shell.Application')
		shell.ShellExecute('pageant.exe', cmd, putty_dir, 'open', 1)
  	end

  	def keygen()
  		putty_gen = File.expand_path('../../../../assets/puttygen.exe', __FILE__)

  		shell = WIN32OLE.new('Shell.Application')
  		shell.ShellExecute(putty_gen, "", "", 'open', 1)
  	end

  	module_function :win_ssh
  	module_function :keygen
  end
end
