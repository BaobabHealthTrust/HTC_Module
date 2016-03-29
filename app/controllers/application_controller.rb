class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception
  before_action :authenticate_user, :except => [:attempt_login, :login, :logout]
  before_filter :save_login_state, :only => [:attempt_login, :login]

  def print_and_redirect(print_url, redirect_url, message = "Printing, please wait...", show_next_button = false, patient_id = nil)
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    @show_next_button = show_next_button
    @patient_id = patient_id
    render :template => 'print/print', :layout => nil
  end

  def next_task(client)
     htc_tasks = ["IN WAITING","IN SESSION","UPDATE HIV STATUS","COUNSELING","HIV TESTING","REFERRAL CONSENT CONFIRMATION",
                          "APPOINTMENT",] ### "ASSESSMENT" after COUNSELING
     current_date = session[:datetime].to_date rescue Date.today
     conselled = encounter_done(client.patient_id, "COUNSELING")
     partner = ActionView::Base.full_sanitizer.sanitize(encounter_done(client.patient_id, "IN SESSION").first.to_s.upcase) rescue ""
     
    htc_tasks.each { |encounter|
              case encounter
                when "UPDATE HIV STATUS"
                   if encounter_done(client.patient_id, encounter).blank?
                      if partner.match(/PARTNER OR SPOUSE/i)
                        link = { "name" =>  "Update Status",
                        "url" => "/couple/status?client_id=#{client.patient_id}"}
                      else
                        link = { "name" =>  "Update Status",
                        "url" => "/client_status/#{client.patient_id}"}
                      end
                      return link
                    end
                when "COUNSELING"
                   if encounter_done(client.patient_id, encounter).blank?
                        link = { "name" =>  "Counseling",
                        "url" => "/client_counseling?client_id=#{client.patient_id}"}
                   
                        return link
                    end
                when "ASSESSMENT"
                   if encounter_done(client.patient_id, encounter).blank?
                        link = { "name" =>  "Assessment",
                        "url" => "/client_assessment/#{client.patient_id}"}
                        return link
                    end

                when "HIV TESTING"
                   if ! conselled.blank?
                        o = ActionView::Base.full_sanitizer.sanitize(conselled.first.to_s).upcase
                        if o.match(/TEST CONCEPT: NO/i)
                            next
                        end
                   end
                   if encounter_done(client.patient_id, encounter).blank?
                     
                        link = { "name" =>  "HIV Testing",
                        "url" => "/client_testing?client_id=#{client.patient_id}"}
                    
                        return link
                    end
                when "REFERRAL CONSENT CONFIRMATION"
                  if client.hiv_status != 'Reactive'
                    next
                  end

                   if ! conselled.blank?
                        o = ActionView::Base.full_sanitizer.sanitize(conselled.first.to_s).upcase
                        if o.match(/TEST CONCEPT: NO/i)
                            next
                        end
                   end
                    if encounter_done(client.patient_id, encounter).blank?
                       
                        link = { "name" =>  "Referral",
                        "url" => "/referral_consent/#{client.patient_id}"}

                        return link
                    end

              when "APPOINTMENT"
                   if ! conselled.blank?
                        o = ActionView::Base.full_sanitizer.sanitize(conselled.first.to_s).upcase
                        if o.match(/TEST CONCEPT: NO/i)
                            next
                        end
                   end
                  if encounter_done(client.patient_id, encounter).blank?
                    #if partner.match(/PARTNER OR SPOUSE/i)
                       # next
                      #else
                        link = { "name" =>  "Appointment",
                        "url" => "/appointment/#{client.patient_id}"}
                    #end
                        return link
                    end
              end
    }
    if partner.match(/PARTNER OR SPOUSE/i)
       link = { "name" =>  "None",
                        "url" => "/client_current_visit?client_id=#{client.patient_id}"}
    else
       link = { "name" =>  "None",
                        "url" => "/clients/#{client.patient_id}"}
    end
       return link
  end

  def encounter_done(patient_id, encounter)
      current_date = session[:datetime].to_date rescue Date.today
      type = EncounterType.where("name = ?", encounter).first.encounter_type_id
      return Encounter.where("patient_id = ? AND encounter_type = ? AND DATE(encounter_datetime) = ?", patient_id, type, current_date  ).order("encounter_datetime desc")
  end

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
			else
				Location.current_location_id = @current_location.id
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
		@is_counselor = @current_user.user_roles.map(&:role).include?('Counselor')
		
		htc_room_tag_id = LocationTag.find_by_name('HTC Counseling Room').id rescue []
		location_tags = LocationTagMap.where("location_id=#{@current_location.id}")
																	.map(&:location_tag_id) rescue []

		if location_tags.include?(htc_room_tag_id) && @is_counselor
			@show_counselling_room = true
		end
		
	end

  def is_supervisor
    is_current = @current_user.user_roles.map(&:role).include?('Supervisor')
    return is_current
  end

  helper_method :is_supervisor
	helper_method :current_user
	helper_method :current_location
	helper_method :show_counselling_room


	def all_htc_facility_locations
  	htc_tags = ["HTC Counseling Room","Other HTC Room"] 
  	htc_tags = htc_tags.map{|l| LocationTag.find_by_name(l).location_tag_id}
    Location.joins(:location_tag_maps)
            .where(:location_tag_map => {:location_tag_id => htc_tags})
	end

  def settings 
    OpenStruct.new YAML.load_file("#{Rails.root}/config/settings.yml")
  end
	
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
