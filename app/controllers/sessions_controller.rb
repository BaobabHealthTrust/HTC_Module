class SessionsController < ApplicationController
  
  def attempt_login
  end

  def login
    location = params[:location].gsub("$", '').squish
  	@location = Location.find_by_name(location) rescue nil
		@user = User.authenticate(params[:username], params[:password]) if @location
		
		
		if @location
			is_counselor = @user.user_roles.map(&:role).include?('Counselor') rescue false
			
			htc_room_tag_id = LocationTag.find_by_name('HTC Counseling Room').id rescue []
			location_tags = LocationTagMap.where("location_tag_id=#{htc_room_tag_id}")
																		.map(&:location_id) rescue []
		
			if location_tags.include?(@location.id) && !is_counselor
				@location = nil
				flash[:alert] = "You are not allow to visit this location"
			end
		end
		
		if @location
			if @user
				flash[:notice] = "You've been logged in."
				session[:user_id] = @user.id
        User.current_user_id = session[:user_id]
				session[:location_id] = @location.id
        session[:datetime] = DateTime.now        
				redirect_to "/"
			else
				flash[:alert] = "Wrong username or password"
				redirect_to log_in_path
			end
		else
				flash[:alert] = "Location: #{location} does not exist!"
				redirect_to log_in_path
		end
  end

  def logout
  
		session[:user_id] = nil
    User.current_user_id = nil
		session[:room_id] = nil
		
		current_location rescue nil
		Location.login_rooms_details.delete(@current_location.name.humanize) rescue nil
		session = nil
		reset_session
		flash[:notice] = "You've been logged out successfully."
		redirect_to "/login"
  end
end
