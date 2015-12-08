class SessionsController < ApplicationController
  
  def attempt_login
  end

  def login
  	flash[:alert] = nil
  	load_location_from_setting if session[:user_id].blank?
    location = params[:location].gsub("$", '').squish rescue nil
    
    redirect_to "/" and return if location.blank?
     
  	@location = Location.find_by_name(location) rescue nil
		@user = User.authenticate(params[:username], params[:password]) if @location
		
		
		if @location
			is_counselor = @user.user_roles.map(&:role).include?('Counselor') rescue false
      is_supervisor = @user.user_roles.map(&:role).include?('Supervisor') rescue false
			
			htc_room_tag_id = LocationTag.find_by_name('HTC Counseling Room').id rescue []
			location_tags = LocationTagMap.where("location_tag_id=#{htc_room_tag_id}")
																		.map(&:location_id) rescue []
		
			if location_tags.include?(@location.id) && !is_counselor && !is_supervisor
				@location = nil
				flash[:alert] = "You are not allowed to visit this location"
			end
		else
			flash[:alert] = "Location: #{location} does not exist!"
		end
		
		if @location
			if @user
				#flash[:notice] = "You've been logged in."
				session[:user_id] = @user.id
        User.current_user_id = session[:user_id]
				session[:location_id] = @location.id       
				redirect_to "/"
			else
				flash[:alert] = "Wrong username or password"
				redirect_to log_in_path
			end
		else
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
  
  def load_location_from_setting
		htc_rooms_names = all_htc_facility_locations.map{|r|r.name.humanize}
  	
  	other_htc_rooms = Settings[:other_htc_rooms]  	
  	location_tag_id = LocationTag.find_by_name("Other HTC Room").location_tag_id 	
  	other_htc_rooms = other_htc_rooms.select do |r|
  											!htc_rooms_names.include?(r.humanize)
  										end

		other_htc_rooms.each do |name|
			create_location(name, location_tag_id)
		end
		  
  	counseling_rooms = Settings[:counseling_rooms]
  	location_tag_id = LocationTag.find_by_name("HTC Counseling Room").location_tag_id							
  	counseling_rooms  = counseling_rooms.select do |r|
  												!htc_rooms_names.include?(r.humanize)
  											end

		counseling_rooms.each do |name|
			create_location(name, location_tag_id)
		end
  end
  
  def create_location(name, location_tag_id)
  	User.current_user_id = User.first.id
		loc_params = {:name => name,:creator => User.current_user_id }

		location = Location.new(loc_params)
		location.id = Location.last.id + 1
		if location.save
			location_tag_map_params = { :location_id => location.id,
																	:location_tag_id => location_tag_id
																}
			location_tag_map = LocationTagMap.create(location_tag_map_params)
			location_tag_map.save
		end
  end

  def server_date
    render :text => Time.now.to_s(:db)
  end
end
