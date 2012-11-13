require 'win32ole'

module Labs
  module Win32

    # covert the path if running under cygwin
    def cygwin_path(path)
      if RbConfig::CONFIG['host_os'] =~ /cygwin/
        return `cygpath -w -p '#{path}'`.strip
      end

      path
    end

  	def win_ssh(user, host, key)
  		_putty_dir = File.expand_path('../../../../assets/', __FILE__)
      putty_dir = cygwin_path(_putty_dir)
      
      _key = cygwin_path(key)

      if RbConfig::CONFIG['host_os'] =~ /mingw/
        pageant = File.expand_path('../../../../assets/pageant.exe', __FILE__)
      else
        pageant = 'pageant.exe'
      end

  		cmd = "\"#{_key}\" -c \"#{putty_dir}/putty.exe\" -A #{user}@#{host}"

  		shell = WIN32OLE.new('Shell.Application')
  		shell.ShellExecute(pageant, cmd, putty_dir, 'open', 1)
  	end

  	def keygen()
  		_putty_gen = File.expand_path('../../../../assets/puttygen.exe', __FILE__)
      putty_gen = cygwin_path(_putty_gen)

  		shell = WIN32OLE.new('Shell.Application')
  		shell.ShellExecute(putty_gen, "", "", 'open', 1)
  	end

    module_function :cygwin_path
  	module_function :win_ssh
  	module_function :keygen
  end
end
