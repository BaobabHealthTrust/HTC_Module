class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user, :except => [:attempt_login, :login, :logout]
  before_filter :save_login_state, :only => [:attempt_login, :login]
  
      

	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
		User.current_user_id = @current_user.id
		@current_user
	end
	
	def current_location

		if session[:location_id]
			@current_location ||= Location.find(session[:location_id]) rescue nil
			
			if @current_location.nil?
				session = nil
				return 
			end
			
			Location.login_rooms_details = {} if Location.login_rooms_details.nil?
			
			if Location.login_rooms_details[@current_location.name.humanize].nil?
				
				#Class variable Hash contains location and user_id
				Location.login_rooms_details[@current_location.name.humanize] = {user_id: @current_user.id}
			end
		end	
	end
	
	def show_counselling_room
		@show_counselling_room = false
		is_counselor = @current_user.user_roles.map(&:role).include?('Counselor')
		
		htc_room_tag_id = LocationTag.find_by_name('HTC Counseling Room').id rescue []
		location_tags = LocationTagMap.where("location_id=#{@current_location.id}")
																	.map(&:location_tag_id) rescue []

		if location_tags.include?(htc_room_tag_id) && is_counselor
			@show_counselling_room = true
		end
		
	end

	helper_method :current_user
	helper_method :current_location
	helper_method :show_counselling_room

	protected 
	
	def authenticate_user
		if session[:user_id]
		  current_user
		  current_location 
		  show_counselling_room
		  return true	
		else
		  redirect_to('/login')
		  return false
		end
	end
	
	def save_login_state
		if session[:user_id]
		  redirect_to(:controller => 'htcs', :action => 'index')
		  return false
		else
		  return true
		end
	end

end
