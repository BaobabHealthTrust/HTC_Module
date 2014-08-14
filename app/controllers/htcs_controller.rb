class HtcsController < ApplicationController
  before_action :set_htc, only: [:show, :edit, :update, :destroy]

  def index
  	tag_id = LocationTag.find_by_name('HTC Counseling Room').id rescue []
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
  
  	tag_id = LocationTag.find_by_name('HTC Counseling Room').id rescue []
		@rooms = Location.joins(:location_tag_maps).where("location_tag_id=?",tag_id)
										 .map{ |r|r.name.humanize } rescue []
  	
  	
  	
  	@dash_board = {}
  	@rooms.each do |r|
			#Dashboard counseling room status report
			@dash_board[r] = {}
			
			#Room state
			status = "In"
			if Location.login_rooms_details[r].nil?
				status = "Out"
				@dash_board[r][:vg_waiting] = "--"
				@dash_board[r][:seen_today] = "--"
			else
				user_id = Location.login_rooms_details[r][:user_id]
				@dash_board[r][:username] = User.find(user_id).username

				#Average patient waiting time 
				@dash_board[r][:vg_waiting] = average_waiting_time_for_user(user_id)
				
				#Total patients seen today so far
				date = session[:datetime].to_date rescue date = Date.today
				@dash_board[r][:seen_today] = total_seen_today_by_user(user_id, date)
			end
			@dash_board[r][:status] = status
			
			#Current Encounter
			@dash_board[r][:latest_encounter_name] rescue nil
			@dash_board[r][:latest_encounter_date] rescue nil
			
			if r == @current_location.name.humanize && !Location.login_rooms_details[r].nil?
					user_id = Location.login_rooms_details[r][:user_id]
					e = Encounter.where("creator = ?", user_id)
											 .order("encounter_datetime DESC").first rescue nil
					
					if !e.nil?
						name = e.name
						datetime = e.encounter_datetime.strftime("On %d-%b-%Y at %H:%M %P")
						@dash_board[r][:latest_encounter_name] = e.name
						@dash_board[r][:latest_encounter_date] = datetime
					end
			end
			
  	end
  	render layout: false
  end
  
  def average_waiting_time_for_user(user_id)
  		in_waiting = EncounterType.find_by_name('IN WAITING').id
  		in_session = EncounterType.find_by_name('IN SESSION').id
  		
			clients_seen_today = Encounter.find_by_sql(
					"SELECT in_waiting.patient_id,
								 in_waiting.encounter_datetime as in_waiting,
								 in_session.encounter_datetime as in_session
					 FROM
							(SELECT * FROM htc_development.encounter
												WHERE encounter_type = #{in_waiting} AND voided = 0 
							) AS in_waiting
							LEFT JOIN
							(SELECT * FROM htc_development.encounter
												WHERE encounter_type = #{in_session}
													AND voided = 0 AND creator = #{user_id}
							) AS in_session
							ON in_waiting.patient_id=in_session.patient_id
									AND DATE(in_waiting.encounter_datetime)=DATE(in_session.encounter_datetime)
					WHERE in_waiting.patient_id IS NOT NULL AND in_session.patient_id IS NOT NULL"
				)
			
				diff = clients_seen_today.map do |e| 
								e.in_session.to_i - e.in_waiting.to_i
				end
				avg_difference = diff.sum/diff.count
  			distance_between(avg_difference)
  end
  
  def total_seen_today_by_user(user_id, date=Date.today) 
  		in_waiting = EncounterType.find_by_name('IN WAITING').id
  		in_session = EncounterType.find_by_name('IN SESSION').id
  		
			clients_seen_today = Encounter.find_by_sql(
					"SELECT in_waiting.patient_id,
								 in_waiting.encounter_datetime as in_waiting,
								 in_session.encounter_datetime as in_session
					 FROM
							(SELECT * FROM htc_development.encounter
												WHERE encounter_type = #{in_waiting} AND voided = 0 
							) AS in_waiting
							LEFT JOIN
							(SELECT * FROM htc_development.encounter
												WHERE encounter_type = #{in_session}
													AND voided = 0 AND creator = #{user_id}
							) AS in_session
							ON in_waiting.patient_id=in_session.patient_id
									AND DATE(in_waiting.encounter_datetime)=DATE(in_session.encounter_datetime)
					WHERE in_waiting.patient_id IS NOT NULL AND in_session.patient_id IS NOT NULL
								AND DATE(in_session.encounter_datetime) = DATE('#{date}')"
				).count  
  end
  
  def distance_between(difference)
    #difference = end_date.to_i - start_date.to_i
    seconds    =  difference % 60
    difference = (difference - seconds) / 60
    minutes    =  difference % 60
    difference = (difference - minutes) / 60
    hours      =  difference % 24
    difference = (difference - hours)   / 24
    days       =  difference % 7
    weeks      = (difference - days)    /  7
    
    return "#{hours}hr, #{minutes}min, #{seconds}sec"
  end
  

end
