class SessionsController < ApplicationController
  
  def attempt_login
  end

  def login
    location = params[:location].gsub("$", '').squish
  	@location = Location.find_by_name(location) rescue nil
		@user = User.authenticate(params[:username], params[:password]) if @location
		
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
		
		current_location
		Location.login_rooms_details.delete(@current_location.name.humanize)
		session = nil
		flash[:notice] = "You've been logged out successfully."
		redirect_to "/login"
  end
end
