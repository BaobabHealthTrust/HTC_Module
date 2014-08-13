class HtcsController < ApplicationController
  before_action :set_htc, only: [:show, :edit, :update, :destroy]

  def index
  	tag_id = LocationTag.find_by_name('HTC Counselling Room').id rescue []
		@rooms = Location.joins(:location_tag_maps).where("location_tag_id=?",tag_id) rescue []
		@date = (session[:datetime].to_date) || Date.today

		@rooms_info = {}
		@rooms.each do |r|
			@rooms_info[r.name] = {}
			@rooms_info[r.name][:max_capacity] = Random.rand(100)
			@rooms_info[r.name][:seen] = @rooms_info[r.name][:max_capacity].to_f
			@rooms_info[r.name][:waiting] = client_seen_in_room(r.name)
			@rooms_info[r.name][:available_space] = 'NaN'
			@rooms_info[r.name][:total_attendance] = 'NaN'
		end
		render layout: false
  end

  def  client_seen_in_room(room, date=Date.today)
		   encounter_type_id = EncounterType.find_by_name('IN SESSION').id
			 Client.joins(:encounters)
		         .where("encounter_type = #{encounter_type_id} AND
		                 DATE(encounter_datetime) = ?",date).count
  end
  
  def swap_desk
		htc_tags = LocationTag.where("name LIKE '%HTC%'").map(&:location_tag_id)
		@locations = Location.joins(:location_tag_maps)
				                .where(:location_tag_map => {:location_tag_id => htc_tags})
				                
  end
  
  def swap
		name = params[:location]
  	htc_tags = LocationTag.where("name LIKE '%HTC%'").map(&:location_tag_id)
  	location = Location.joins(:location_tag_maps).where(:location_tag_map => {:location_tag_id => htc_tags},
  																					 :location => {:name => name}).first
  	
  	if location.nil?
  		@alert = "Error: Location not found"
  		redirect_to(:controller => 'htcs', :action => 'swap_desk')
  	else
  		session[:location_id] = location.id
  		current_location
  		redirect_to(:controller => 'htcs', :action => 'index')
  	end
  end
  
  def dashboard
  
  	tag_id = LocationTag.find_by_name('HTC Counselling Room').id rescue []
		@rooms = Location.joins(:location_tag_maps).where("location_tag_id=?",tag_id) rescue []
  	
  	render layout: false
  end

end
