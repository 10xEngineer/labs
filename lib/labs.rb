require "labs/version"

require 'labs/config'
require 'commander'
require 'commander/delegates'

#
# snippet from commander:lib/commander/import.rb needed when manually calling
# run! instead of relying on at_exit { run! } (sic!).
#
include Commander::UI
include Commander::UI::AskForClass
include Commander::Delegates

$terminal.wrap_at = HighLine::SystemExtensions.terminal_size.first - 5 rescue 80 if $stdin.tty?

class String
  def rchomp(sep = $/)
    self.start_with?(sep) ? self[sep.size..-1] : self
  end
end

module Labs
	CONFIG_FILE = ".labs.rc"
end
