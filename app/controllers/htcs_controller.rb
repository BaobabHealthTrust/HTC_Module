class HtcsController < ApplicationController
  before_action :set_htc, only: [:show, :edit, :update, :destroy]

  def index
  	tag_id = LocationTag.find_by_name('HTC Counseling Room').id rescue []
		@rooms = Location.joins(:location_tag_maps).where("location_tag_id=?",tag_id) rescue []
		@date = (session[:datetime].to_date rescue nil)

		if @date.nil?
			session[:user_id] = nil
			redirect_to "/login" and return
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
  	@agv_agv_waiting_time = 0
  	@avg_count = 0
  	
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
				
				@dash_board[r][:user_id] = user_id
				@dash_board[r][:username] = User.find(user_id).username

				#Average patient waiting time 
				@dash_board[r][:vg_waiting] = average_waiting_time_for_user(user_id)
				@agv_agv_waiting_time += @dash_board[r][:vg_waiting][:diff]
				@avg_count += 1
				
				#Total patients seen today so far
				date = session[:datetime].to_date rescue date = Date.today
				@dash_board[r][:seen_today] = total_seen_today_by_user(user_id, date)
			end
			@dash_board[r][:status] = status
			
			#Latest Encounter
			@dash_board[r][:latest_encounter_name] rescue nil
			@dash_board[r][:latest_encounter_date] rescue nil
			
			if !Location.login_rooms_details[r].nil?
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
  	
  	@agv_agv_waiting_time = @agv_agv_waiting_time/@avg_count rescue 0
  	@agv_agv_waiting_time = distance_between(@agv_agv_waiting_time)
  	
  	@total_on_waiting_list = waiting_list_total rescue 0
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
				avg_difference = diff.sum/diff.count rescue 0
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
    diff = difference
    seconds    =  difference % 60
    difference = (difference - seconds) / 60
    minutes    =  difference % 60
    difference = (difference - minutes) / 60
    hours      =  difference % 24
    difference = (difference - hours)   / 24
    days       =  difference % 7
    weeks      = (difference - days)    /  7
    
    return {hrs: hours, min: minutes, sec: seconds, diff: diff}
  end
  
  def waiting_list_total
		date = session[:datetime].to_date rescue Date.today
		encounter_type_id = EncounterType.find_by_name('IN WAITING').id
		@clients = Client.joins(:encounters)
				            .where("encounter_type = #{encounter_type_id} AND
				                    DATE(encounter_datetime) = '#{date}'")
				                    .order('encounter_datetime DESC')
				                    
		@clients = @clients.reject{|c| c.current_state.name != "IN WAITING"} rescue []
		@clients.count
	end

end
