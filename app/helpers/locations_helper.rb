module LocationsHelper
	def current_location_occupied
		loc = Location.login_rooms_details.keys.map{|r| "'#{r}'"} rescue []
		"[#{loc.join(",")}]".html_safe
	end
end
