module ApplicationHelper

	def get_global_property_value(property)
		Settings[property] rescue nil
	end
end
