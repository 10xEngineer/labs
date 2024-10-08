require 'labs/version'
require 'labs/utils/cli'
require 'labs/config'
require 'commander'
require 'commander/delegates'

require 'labs/machines'

#
# snippet from commander:lib/commander/import.rb needed when manually calling
# run! instead of relying on at_exit { run! } (sic!).
#
include Commander::UI
include Commander::UI::AskForClass
include Commander::Delegates

$terminal.wrap_at = HighLine::SystemExtensions.terminal_size.first - 5 rescue 80 if $stdin.tty?
$is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)

module Labs
	CONFIG_FILE = ".labs.rc"
end
