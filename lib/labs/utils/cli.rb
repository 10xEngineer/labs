# encoding: utf-8

module Labs
	class CommandError < RuntimeError; end
end

class String
  def rchomp(sep = $/)
    self.start_with?(sep) ? self[sep.size..-1] : self
  end
end
