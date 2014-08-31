class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy,
                                    :add_to_unallocated, :remove_from_waiting_list,
                                    :assign_to_counseling_room, :village]

	#skip_before_action :village

  def index
    #@clients = Client.all
  end

  def show
			current_date = session[:datetime].to_date rescue Date.today
			@accession_number = @client.accession_number
			@residence = PersonAddress.find_by_person_id(@client.id).address1
			@names = PersonName.find_by_person_id(@client.id)
			person = Person.find(@client.id)
			@status  = @client.current_state(current_date) 
			@firststatus  = @client.first_state rescue "NaN"
			@age = person.age(current_date)
			
			render layout: false
  end

  def new
		if ! params[:name_id].blank?
				@names = PersonName.where("person_id = #{params[:name_id]} AND voided = 0")				
				@names.each do |name|
					 name.voided = 1
					 name.save! 					
				end

				@new_name = PersonName.create(preferred: '0', person_id: params[:name_id], 
															given_name: params[:first_name], family_name: params[:surname], 
															creator: current_user.id)
				redirect_to "/clients/#{params[:name_id]}" and return

		elsif ! params[:gender].blank? and ! params[:dob].blank?
			current_number = 1
			current = session[:datetime].to_date rescue Date.today
			identifier_type = ClientIdentifierType.find_by_name("HTC Identifier").id
			type = ClientIdentifier.find(:last, 
																	 :conditions => ["identifier_type = ? AND identifier LIKE ?",
																	  identifier_type, "%#{current.year.to_s}"])
			type = type.identifier.split("-")[0].to_i rescue 0
			identifier = current_number + type
			
			birthdate_estimated = false

			birth_date = params[:dob].split("/")
			birth_year = birth_date[2]
			birth_month = birth_date[1]
			birth_day = birth_date[0]

			birthdate = params[:dob]

			if birth_month == "?"
				birthdate_estimated = true
				birth_month = 7
			end
			
			if birth_day == "?"
				birthdate_estimated = true
				birth_day = 1
			end
			
			birthdate = "#{birth_day}/#{birth_month}/#{birth_year}" if birthdate_estimated == true
			
			@person = Person.create(gender: params[:gender], birthdate: birthdate,
															birthdate_estimated: birthdate_estimated,
															creator: current_user.id)
    	@client = Client.create(patient_id: @person.person_id, creator: current_user.id) if @person
			@address = PersonAddress.create(person_id: @person.person_id, 
															address1: params[:residence], creator: current_user.id) if @person
			@identifier = ClientIdentifier.create(identifier_type: identifier_type, 
															patient_id: @client.id, 
															identifier: "#{identifier}-#{current.year}", creator: current_user.id)
			
			current = session[:datetime].to_datetime.strftime("%Y-%m-%d %H:%M:%S") rescue DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
			write_encounter("IN WAITING", @person, current)
      #print_new_accession(@client.patient_id)
		end
		
		redirect_to action: 'search_results', residence: @address.address1, 
											gender: @person.gender, date_of_birth: @person.birthdate
  end

  def edit
  end

  def tasks
      	@client = Client.find(params[:client_id])
  end
  
	def demographics
		 		@client = Client.find(params[:client_id])
		 		@residence = PersonAddress.find_by_person_id(@client.id).address1
	end

	def counseling
			@client = Client.find(params[:client_id])
      @protocol = []
			CounselingQuestion.where("retired = 0 AND child = 0").order("position ASC").each {|protocol|
          @protocol << protocol
          ChildProtocol.where("parent_id = #{protocol.id}").each{|child|
             CounselingQuestion.where("question_id = #{child.protocol_id} AND retired = 0").order("position ASC").each{|x|
               @protocol << x
             }
          }
      }
      redirect_to client_path(@client.id) if @protocol.blank?
	end

	def testing
  		@client = Client.find(params[:client_id])
  end
	
	def referral_consent
			
	end

  def appointment
  		today = (session[:datetime].to_date rescue Date.today)
  		@start_week_date = today - 1.week
  		@initial_date =  today + 1.day
  		@end_week_date = today + 2.years
      render :layout => false
  end
  
	def locations
			location = Location.where("name LIKE '%#{params[:search]}%'")
			location = location.map do |locs|
      "#{locs.name}"
    end
    render :text => location.join("\n") and return
	end

	def village
			location = Village.where("name LIKE '%#{params[:search]}%'")
			location = location.map do |locs|
      "#{locs.name}"
    end
    render :text => location.join("\n") and return
	end
	
	def first_name
			person = PersonName.where("given_name LIKE '%#{params[:search]}%'")
			person = person.map do |locs|
      "#{locs.given_name}"
    end
    render :text => person.join("\n") and return
	end

	def last_name
			person = PersonName.where("family_name LIKE '%#{params[:search]}%'")
			person = person.map do |locs|
      "#{locs.family_name}"
    end
    render :text => person.join("\n") and return
	end

  def printouts
    render layout: false
  end

  def print_accession
    client = Client.find(params[:id])
		print_string = get_accession_label(client)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:id]}#{rand(10000)}.lbl", :disposition => "inline")
		#redirect_to '/locations'
  end

  def print_new_accession(client_id)
    client = Client.find(client_id)
		print_string = get_accession_label(client)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{client_id}#{rand(10000)}.lbl", :disposition => "inline")
		#redirect_to '/locations'
  end

  def print_summary
    client = Client.find(params[:id])
		print_string = get_summary_label(client)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:id]}#{rand(10000)}.lbl", :disposition => "inline")
		#redirect_to '/locations'
  end

    def get_summary_label(client)
    current = session[:datetime].to_date rescue Date.today
    return unless client.patient_id
    tested = client.tested(current)
    answer = "No"
    answer = "Yes" if ! tested.blank?
    label = ZebraPrinter::StandardLabel.new
    label.draw_text("Visit Date: #{current.strftime('%d/%m/%Y')}",75, 30, 0, 2, 2, 1, false)
    label.draw_text("Accession Number: #{client.accession_number}",75, 75, 0, 3, 2, 1, false)
    label.draw_text("Tested: #{answer}",75, 100, 0, 2, 2, 1, false)
    if ! tested.blank?
        status = tested.to_s.split(':')[1]
        label.draw_text("status: #{status}",75, 130, 0, 2, 2, 1, false)
    end
    label.print(2)

  end

  def get_accession_label(client)
    return unless client.patient_id
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false,"#{client.accession_number rescue ''}")
    label.draw_multi_text("Accession Number")
    label.print(1)
  end

	def current_visit
		current_date = session[:datetime].to_date rescue Date.today
		@client = Client.find(params[:client_id])
		@status  = @client.current_state(current_date) rescue "NaN"
		@firststatus  = @client.first_state rescue []
		@finalstatus = @client.final_state
		@encounters = Encounter.where("encounter.voided = ? and patient_id = ? and encounter.encounter_datetime >= ? and encounter.encounter_datetime <= ?", 0, params[:client_id], current_date.strftime("%Y-%m-%d 00:00:00"), current_date.strftime("%Y-%m-%d 23:59:59")).includes(:observations).includes(:counseling_answer).order("encounter.encounter_datetime DESC")
    @creator_name = {}
    @encounters.each do |encounter|
      id = encounter.creator
      user_name = User.find(id).person.names.first rescue ""
      @creator_name[id] = '(' + (user_name.given_name rescue "").to_s + '. ' + (user_name.family_name rescue "").to_s + ')'
    end
    
    render layout: false
	end
	
  def get_previous_encounters(patient_id)
    start_date = (session[:datetime].to_date rescue Date.today.to_date) - 1.days
		end_date = ((start_date) - 7.days).to_s + ' 00:00:00'
    start_date = start_date.to_s + ' 23:59:59'
   previous_encounters = Encounter.where("encounter.voided = ? and patient_id = ? and encounter.encounter_datetime <= ?", 0, patient_id, start_date).includes(:observations).order("encounter.encounter_datetime DESC").limit(20)
		
    return previous_encounters
  end

  def get_previous_month_encounters(patient_id)
    start_date = (session[:datetime].to_date rescue Date.today.to_date) - 1.days
		end_date = ((start_date) - 1.months).to_s + ' 00:00:00'
    start_date = start_date.to_s + ' 23:59:59'
   previous_encounters = Encounter.where("encounter.voided = ? and patient_id = ? and encounter.encounter_datetime <= ? AND encounter.encounter_datetime >= ?", 0, patient_id, start_date, end_date).includes(:observations).order("encounter.encounter_datetime DESC")
		
    return previous_encounters
  end

	def previous_month

	end	
	
  def previous_visit
    @previous_visits  = get_previous_encounters(params[:client_id])
  end

  def create
    @client = Client.new(client_params)

    if @client.save

    else

    end

  end

  def update
		if @client.update(client_params)

		else
		end
  end

  def destroy
    @client.destroy
  end

	def search
			 
	end
	
	def search_results
		 current_date = session[:datetime].to_date rescue Date.today.to_date
		 identifier_type = ClientIdentifierType.find_by_name("HTC Identifier").id

		 if !params[:accession_number].blank? || !params[:barcode].blank?

				accession = params[:barcode] if  ! params[:barcode].blank?
				accession = params[:accession_number] if ! params[:accession_number].blank?

			  @accession = ClientIdentifier.where("identifier = '#{accession}' 
											AND identifier_type = #{identifier_type} AND voided = 0").last rescue []

				if @accession.blank?
					flash[:notice] = "Invalid accession number...."
					redirect_to "/search" and return
				end
				@residence = PersonAddress.find_by_person_id(@accession.patient_id).address1
				@scanned = Client.find(@accession.patient_id)
				
				if params[:add_to_session] =="true" || !params[:barcode].blank?
					if !@scanned.current_state(current_date).blank?
						if @scanned.current_state(current_date).name == "IN WAITING"
						 assign_to_counseling_room(@scanned)
						end
					else
						redirect_to "/search" and return
					end
				end
				
				redirect_to "/clients/#{@scanned.patient_id}" and return
		 else
		 		
			
			birthdate_estimated = false

			birth_date = params[:date_of_birth].split("/")
			birth_year = birth_date[2]
			birth_month = birth_date[1]
			birth_day = birth_date[0]

			birthdate = params[:date_of_birth]

			if birth_month == "?"
				birthdate_estimated = true
				birth_month = 7
			end
			
			if birth_day == "?"
				birthdate_estimated = true
				birth_day = 1
			end
			
			birthdate = "#{birth_day}/#{birth_month}/#{birth_year}" if birthdate_estimated == true
		 		@clients = Client.find_by_sql("SELECT * FROM patient p
											INNER JOIN person pe ON pe.person_id = p.patient_id 
											INNER JOIN person_address pn ON pn.person_id = pe.person_id
											LEFT JOIN patient_identifier pi ON pi.patient_id = p.patient_id
											WHERE pn.address1 = '#{params[:residence]}' AND pe.gender = '#{params[:gender]}'
											AND DATE(pe.birthdate) = '#{birthdate.to_date}' AND p.voided = 0
											AND pi.identifier_type = #{identifier_type} AND pi.voided = 0 AND
											pn.voided = 0 ORDER BY pi.identifier DESC LIMIT 20") rescue []
				
				sp = ""
				@side_panel_date = ""
				@client_list = ""
				@clients_info = []
				
				@clients.each do |client|
					id= client.id
					accession = client.accession_number
					age = client.person.age
					gender = client.person.gender
					birth = client.person.birthdate.to_date.to_formatted_s(:rfc822) rescue "NaN"
					residence = PersonAddress.find_by_person_id(id).address1
					status = client.current_state(current_date).name rescue ""
					last_visit = client.encounters.last.encounter_datetime.to_date
																				.to_formatted_s(:rfc822) rescue nil
					last_visit = Date.today.to_date.to_formatted_s(:rfc822) if last_visit.nil?
					date_today = session[:datetime].to_date rescue Date.today.to_date
					days_since_last_visit = (date_today - last_visit.to_date).to_i
					
					@clients_info << { id: id, accession: accession,
														 birth: birth, gender: gender, residence: residence}
					
					@side_panel_date += sp + "#{id} : { id: #{id},
											accession_number: '#{accession}', status: '#{status}',
											age: #{age}, gender: '#{gender}', last_visit: '#{last_visit}',
											birthDate: '#{birth}', residence: '#{residence.humanize}',
											days_since_last_visit: '#{days_since_last_visit}'}"
					sp = ','
				end
				
     end
     render layout: false
	end
	
	def waiting_list
		 current_date = session[:datetime].to_date rescue Date.today.to_date
     encounter_type_id = EncounterType.find_by_name('IN WAITING').id
		 @clients = Client.joins(:encounters)
                      .where("encounter_type = #{encounter_type_id} AND
                              DATE(encounter_datetime) = ?", current_date)
                              .order('encounter_datetime DESC')

     @clients = @clients.reject{|c| c.current_state(current_date).name != "IN WAITING"} rescue []
     
     @waiting = []
     @clients.each do |c|
			datetime = c.encounters.first.encounter_datetime
			time = datetime.strftime("%I:%M")
			date = datetime.to_date.to_formatted_s(:rfc822)
			birth = c.person.birthdate.to_date.to_formatted_s(:rfc822) rescue "NaN"
			residence = PersonAddress.find_by_person_id(c.id).address1

			last_visit = c.encounters.last.encounter_datetime.to_date
																		.to_formatted_s(:rfc822) rescue nil
			last_visit = Date.today.to_date.to_formatted_s(:rfc822) if last_visit.nil?
			date_today = session[:datetime].to_date rescue Date.today.to_date
			days_since_last_visit = (date_today - last_visit.to_date).to_i
			
     	@waiting << { id: c.id, accession_number: c.accession_number,
     							  age: c.person.age, gender: c.person.gender,
     							  datetime: datetime, date: date, time: time,
     							  birthDate: birth, address: residence,
     							  days_since_last_visit: days_since_last_visit}
     end
     
     @waiting = @waiting.sort{|a, b| a[:datetime].strftime("%Y-%m-%d %H:%M:%S").to_datetime <=> b[:datetime].strftime("%Y-%m-%d %H:%M:%S").to_datetime}
     
     sp = ""
     @w = ""
     @side_panel_date = "";
     
			@waiting.each do |i|
				@w += sp + "{ id: #{i[:id]}, accession_number: '#{i[:accession_number]}',
										age: #{i[:age]}, gender: '#{i[:gender]}',
										datetime: '#{i[:datetime].to_s}', date: '#{i[:date]}', 
										time: '#{i[:time]}', birthDate: '#{i[:birthDate]}' }"
				
				@side_panel_date += sp + "#{i[:id]} : { id: #{i[:id]},
										accession_number: '#{i[:accession_number]}',
										age: #{i[:age]}, gender: '#{i[:gender]}',
										datetime: '#{i[:datetime].to_s}', date: '#{i[:date]}', time: '#{i[:time]}',
										birthDate: '#{i[:birthDate]}', residence: '#{i[:address].humanize}',
										days_since_last_visit: '#{i[:days_since_last_visit]}'}"
				sp = ','
			end

     render layout: false
	end
  
  def add_to_unallocated
    write_encounter('IN WAITING', @client)
    redirect_to waiting_list_path
  end
  
  def remove_from_waiting_list
  	encounter_type_id = EncounterType.find_by_name('IN WAITING').id
		@client.encounters.where("encounter_type = #{encounter_type_id} AND
															DATE(encounter_datetime) = '#{Date.today}'")
											.each {|e| e.void(reason = "cancelled HTC encounter")}
		redirect_to waiting_list_path
  end
  
  def assign_to_counseling_room(client)
    write_encounter('IN SESSION', client)
  end


	def write_encounter(encounter_type, person, current = DateTime.now)
			current = session[:datetime] if !session[:datetime].blank?
			type = EncounterType.find_by_name(encounter_type).id
			
			current_location = @current_location if current_location.nil?
			encounter = Encounter.create(encounter_type: type, patient_id: person.id,
									encounter_datetime: current.to_datetime.strftime("%Y-%m-%d %H:%M:%S"),
									creator: current_user.id)
	end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id]) rescue nil
      redirect_to  htcs_path and return if @client.nil?
      @client
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params[:client]
    end
end
