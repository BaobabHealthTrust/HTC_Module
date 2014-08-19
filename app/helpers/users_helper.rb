module UsersHelper

	def current_logged_in_user_ids
		log = Location.login_rooms_details.values.map{|v| v[:user_id]} rescue []
		"[#{log.join(",")}]"
	end
end
