# encoding: utf-8

def pluralize(resource)
	_res = resource.downcase

	case _res
	when "machine"
		return "machines"
	when "snapshot"
		return "snapshots"
	when "pool"
		return "pools"
	when "process"
		return "processes"
	else
		return "#{res}s"
	end
end