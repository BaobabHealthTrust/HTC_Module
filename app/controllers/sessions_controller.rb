class SessionsController < ApplicationController
  
  def attempt_login
  end

  def login
  	@location = Location.find_by_name(params[:location]) rescue nil
		@user = User.authenticate(params[:username], params[:password]) if @location
		
		if @location
			if @user
				flash[:notice] = "You've been logged in."
				session[:user_id] = @user.id
				session[:location_id] = @location.id				
				redirect_to "/"
			else
				flash[:alert] = "Wrong username or password"
				redirect_to log_in_path
			end
		else
				flash[:alert] = "Location: #{params[:location]} does not exist!"
				redirect_to log_in_path
		end
  end

  def logout
  
		session[:user_id] = nil
		session[:room_id] = nil
		flash[:notice] = "You've been logged out successfully."
		redirect_to "/login"
  end
end
