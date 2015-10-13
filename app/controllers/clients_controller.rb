class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy,
                                    :add_to_unallocated, :remove_from_waiting_list,
                                    :assign_to_counseling_room, :village, :confirm]

	#skip_before_action :village

  def index
    #@clients = Client.all
  end

  def show
    
      @task = next_task(@client)
			current_date = session[:datetime].to_date rescue Date.today
			@accession_number = @client.accession_number
			@residence = PersonAddress.find_by_person_id(@client.id).address1
			@names = PersonName.find_by_person_id(@client.id)
			person = Person.find(@client.id)
			@status  = @client.current_state(current_date) 
			@firststatus  = @client.first_state rescue "NaN"
			@age = person.age(current_date)
      spouse = RelationshipType.where("a_is_to_b = 'spouse/partner'").first.relationship_type_id
      @relation = Relationship.where("person_a = ? OR person_b = ? AND relationship = ?",
                          @client.id, @client.id, spouse).first rescue []
       @string = ""
       if ! @relation.blank?
           @relation = Client.find(@relation.person_a) if @relation.person_a != @client.id
           @relation = Client.find(@relation.person_b) if @relation.person_b != @client.id rescue @relation
           @string = "Partner: #{@relation.person.names.first.given_name rescue ''} #{@relation.person.names.first.family_name rescue ''}"
       end
         
      @all_encounters = {}
      state_encounters = ['IN WAITING', 'IN SESSION','Counseling',
												'HIV Testing', 'Referral Consent Confirmation','ASSESSMENT',"UPDATE HIV STATUS",
												'Appointment']
      state_encounters.each{|encounter|
        @all_encounters[encounter.upcase] = ""
      }
      ids = []
		EncounterType.where("name IN (?)",state_encounters)
								 .each do |e|
										ids << e.id
                    @all_encounters[e.name.upcase] = '#FF4040'
									end

	 Encounter.joins(:type).where("encounter_type IN (?) AND DATE(encounter_datetime)= ? 
                          AND encounter.voided = 0 AND encounter.patient_id = ?", ids, current_date, person.person_id)
                .each{|state|
                  @all_encounters[state.name.upcase] = "#E0EEEE"
                }
      
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
    
      if current.month >= 7
         string = "#{current.year.to_s}"
      else
        string = "#{(current.year - 1).to_s}"
      end

			identifier_type = ClientIdentifierType.find_by_name("HTC Identifier").id
			type = ClientIdentifier.find(:last, 
																	 :conditions => ["identifier_type = ? AND identifier LIKE ?",
																	  identifier_type, "%#{string}"])
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

      if !params[:firstname].blank? || !params[:surname].blank?
        @new_name = PersonName.create(preferred: '0', person_id: @person.id,
            given_name: params[:firstname], family_name: params[:surname],
            creator: current_user.id) if @person
      end

      if !params[:address2].blank?
        @address.address2 = params[:address2]
      end

      if !params[:ta].blank?
        @address.county_district = params[:ta]
      end

      @address.save if @person

      ["Occupation", "Cell Phone Number", "Office Phone Number", "Home Phone Number", "Landmark Or Plot Number"].each do |name|

        next if params["#{name}"].blank?

        uuid =  ActiveRecord::Base.connection.select_one("SELECT UUID() as uuid")['uuid']
        value = params["#{name}"]
        type = PersonAttributeType.where("name = ?", name).first.id

        next if type.blank?

        attribute = PersonAttribute.create(
            person_id: @person.id,
            value: value,
            creator: current_user.id,
            person_attribute_type_id: type,
            uuid: uuid
        )

      end if @person

			@identifier = ClientIdentifier.create(identifier_type: identifier_type, 
															patient_id: @client.id, 
															identifier: "#{identifier}-#{string}", creator: current_user.id)
			
			current = session[:datetime].to_datetime.strftime("%Y-%m-%d %H:%M:%S") rescue DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
			write_encounter("IN WAITING", @person, current)
		end

		session[:show_new_client_button] = false
		redirect_to action: 'search_results', residence: @address.address1, 
											gender: @person.gender, date_of_birth: @person.birthdate
  end

  def search_couple

  end

  def edit
  end

  def tasks
      	@client = Client.find(params[:client_id])
  end
  
	def demographics
        @id = params[:client_id]
        if params[:partner_id]
          @id = params[:partner_id]
        end
		 		@client = Client.find(@id)
        address = PersonAddress.find_by_person_id(@client.id)
		 		@residence = address.address1
        @ta = address.county_district
        @home_district = address.address2
         type = PersonAttributeType.where("name = 'occupation'").first.id rescue ""
         @occupation = PersonAttribute.where("person_id = ? AND person_attribute_type_id =?", @id, type).first.value rescue ""
         type = PersonAttributeType.where("name = 'Home Phone Number'").first.id rescue ""
         @home_phone_number = PersonAttribute.where("person_id = ? AND person_attribute_type_id =?", @id, type).first.value rescue ""
          type = PersonAttributeType.where("name = 'Office Phone Number'").first.id rescue ""
         @office_phone_number = PersonAttribute.where("person_id = ? AND person_attribute_type_id =?", @id, type).first.value rescue ""
          type = PersonAttributeType.where("name = 'Cell Phone Number'").first.id rescue ""
         @cell_phone_number = PersonAttribute.where("person_id = ? AND person_attribute_type_id =?", @id, type).first.value rescue ""
         type = PersonAttributeType.where("name = 'Landmark Or Plot Number'").first.id rescue ""
         @land_mark = PersonAttribute.where("person_id = ? AND person_attribute_type_id =?", @id, type).first.value rescue ""
	end

  def demographics_edit
      	@client = Client.find(params[:id])
        @occupation = ["Business", "Craftsman","Domestic worker","Driver","Farmer","Health worker",
          "Housewife","Mechanic","Messenger","Office worker","Police","Preschool child", "Salesperson",
          "Security guard","Soldier","Student","Teacher","Other","Unknown"]
        @land_mark = ["School","Police","Church","Mosque","Borehole"]
  end

  def modify_field

    client = Client.find(params[:id])
    if  params[:home_phone_number] || params[:cell_phone_number] || params[:office_phone_number] || params[:occupation] || params[:land_mark]
     uuid =  ActiveRecord::Base.connection.select_one("SELECT UUID() as uuid")['uuid']
        if params[:occupation]
          value = params[:occupation]
          name = "Occupation"
        elsif params[:home_phone_number]
          value = params[:home_phone_number]
          name = "Home Phone Number"
        elsif params[:office_phone_number]
          value = params[:office_phone_number]
          name = "Office Phone Number"
        elsif params[:cell_phone_number]
          value = params[:cell_phone_number]
          name = "Cell Phone Number"
       elsif params[:land_mark]
          value = params[:land_mark]
          name = "Landmark Or Plot Number"
        end
        
         type = PersonAttributeType.where("name = ?", name).first.id
         available = PersonAttribute.where("person_id = ? AND person_attribute_type_id =?", params[:id], type)
         (available || []).each{|attribute|
           attribute.voided = 1
           attribute.save
         }
      attribute = PersonAttribute.create(person_id: params[:id],
        value: value, creator: current_user.id,
        person_attribute_type_id: type, uuid: uuid)

    elsif params[:firstname] || params[:surname]
      given_name = nil
      family_name = nil
      names = PersonName.where("person_id = #{params[:id]} AND voided = 0 ")

      unless names.blank?
        given_name = names.first.given_name
        family_name = names.first.family_name
      end

			names.each do |name|
					 name.voided = 1
					 name.save!
				end

        given_name = params[:firstname] if params[:firstname]
        family_name = params[:surname] if params[:surname]
				new_name = PersonName.create(preferred: '0', person_id: params[:id],
															given_name: given_name, family_name: family_name,
															creator: current_user.id)
        # raise new_name.to_yaml
    elsif params[:gender] || params[:date_of_birth]
        person = Person.find(params[:id])
        gender = person.gender
        birthdate = person.birthdate
        gender = params[:gender] if params[:gender]
        if params[:date_of_birth]
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

            if birthdate_estimated == true
              birthdate = "#{birth_day}/#{birth_month}/#{birth_year}"
              person.birthdate_estimated = 1
            end

        end
        person.gender = gender
        person.birthdate = birthdate
        person.save
    elsif params[:ta] || params[:address1] || params[:address2]

        addresses = PersonAddress.where("person_id = ?", params[:id])
        address1 = nil
        address2 = nil
        county_district = nil

        if ! addresses.blank?
           if addresses.first.address2.blank? and addresses.first.county_district.blank?
              addresses.first.address1 = params[:address1] if params[:address1]
              addresses.first.address2 = params[:address2] if params[:address2]
              addresses.first.county_district = params[:ta] if params[:ta]
              addresses.first.save
              redirect_to "/client_demographics?client_id=#{params[:id]}" and return
           elsif
             address1 = addresses.first.address1
             address2 = addresses.first.address2
           county_district = addresses.first.county_district

             (addresses || []).each{|address|
               address.voided = 1
               address.save
             }
           end
        end

       address1 = params[:address1] if params[:address1]
       address2 = params[:address2] if params[:address2]
       county_district = params[:ta] if params[:ta]

       new_address = PersonAddress.create(person_id: params[:id],
                        address1: address1, address2: address2, county_district: county_district, creator: current_user.id)
    end

    if params[:request_url].blank?
      redirect_to "/client_demographics?client_id=#{params[:id]}"
    else
      redirect_to params[:request_url]
    end
  end
  
  def status
     @client = Client.find(params[:id])
     if @client.partner_present == true #and ! session[:partner].blank?
       #raise @task.to_yaml
       @task = next_task(@client)
        if @task["name"]== "Update Status"
            @task["url"] = "/client_status/#{@client.patient_id}?config=couple"
        end
       redirect_to @task["url"] if ! encounter_done(@client.patient_id, "UPDATE HIV STATUS").blank?
     end
     @age = @client.person.age
  end

  def assessment
    @client = Client.find(params[:id])
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

  def early_infant_diagnosis
    @client = Client.find(params[:id])
    current_date = (session[:datetime].to_date rescue Date.today)
    #raise User.current.inspect
    if request.post?
      test_reasons = params[:test_reasons].split(";")
      encounter_type = EncounterType.find_by_name("EID VISIT").id

      ActiveRecord::Base.transaction do
        encounter = @client.encounters.find(:last, :conditions => ["DATE(encounter_datetime) =? AND
              encounter_type =?", current_date, encounter_type])

        encounter = @client.encounters.create({:encounter_type => encounter_type, 
            :encounter_datetime => current_date}) if encounter.blank?

        test_reasons.each do |test_reason|
          encounter.observations.create({
              :person_id => @client.id,
              :concept_id => Concept.find_by_name("REASON FOR TEST").id,
              :value_text => test_reason,
              :creator => User.current.id
          })
        end
        
      end
      
      redirect_to("/eid_care_giver/#{@client.id}") and return
    end
  end

  def early_infant_diagnosis_menu
    @client = Client.find(params[:id])
    if request.post?
      eid_test_question = params[:eid_test_question].squish.downcase
      redirect_to ("/early_infant_diagnosis/#{@client.id}") and return if eid_test_question == 'request'
      redirect_to ("/early_infant_diagnosis_results/#{@client.id}") and return if eid_test_question == 'result'
    end
  end

  def early_infant_diagnosis_results
    @client = Client.find(params[:id])
  end

  def eid_care_giver
    @client = Client.find(params[:id])
    render layout: false
  end

  def care_giver_search_results

  end

  def hiv_viral_load
    
  end

  def hiv_viral_load_menu
    @client = Client.find(params[:id])
    if request.post?
      vl_question = params[:vl_question].squish.downcase
      redirect_to ("/hiv_viral_load/#{@client.id}") and return if vl_question == 'request'
      redirect_to ("/hiv_viral_load_results/#{@client.id}") and return if vl_question == 'result'
    end
  end

  def hiv_viral_load_results
    
  end

  def find_register_caregiver

  end
  
  def extended_testing
      @client = Client.find(params[:id])
      @kits, @remaining, @testing = Kit.kits_available(current_user)
  end
  
  def testing
  
     @kits, @remaining, @testing = Kit.kits_available(current_user)
     
      current_date = (session[:datetime].to_date rescue Date.today)
  		@client = Client.find(params[:client_id])
      type = EncounterType.find_by_name("HIV testing").encounter_type_id
      result = ConceptName.where("name = 'Result of hiv test'").first.concept_id
      obs =   Observation.where("concept_id = ? AND person_id = ? AND DATE(obs_datetime) <", result, params[:client_id], current_date).order(obs_datetime: :desc).first rescue []
      last = obs.to_s.split(':')[1].squish rescue []
      @last_date = 0
      unless last.blank?
         if (current_date.to_date.mjd - obs.obs_datetime.to_date.mjd) > 28 || last.to_s.match(/Inconclusive/i) || last.to_s.match(/Positive/i) || last.to_s.match(/Exposed Infant/i)
             redirect_to  "/extended_testing/#{@client.id}" and return
         end
      end
      concept = ConceptName.where("name = 'last HIV test'").first.concept_id
      last_test = Observation.where("concept_id = ? AND person_id = ?", concept, params[:client_id]).order(obs_datetime: :desc).first.to_s.split(':')[1].squish rescue []
      unless last_test.blank?
         if last_test.match(/Last Positive/i) || last_test.match(/Last Exposed Infant/i) || last_test.match(/Last Inconclusive/i)
              redirect_to  "/extended_testing/#{@client.id}" and return
         end
      end
    concept = ConceptName.where("name = 'Mother HIV status'").first.concept_id
    @mother_status =  Observation.where("concept_id = ? AND person_id = ?", concept, params[:client_id]).order(obs_datetime: :desc).first.to_s.split(':')[1].squish rescue ""
    concept = ConceptName.where("name = 'Client Risk Category'").first.concept_id
    @risk = Observation.where("concept_id = ? AND person_id = ?", concept, params[:client_id]).order(obs_datetime: :desc).first.to_s.split(':')[1].squish rescue ""

    unless @risk.blank?
        if @risk.upcase =="AVD+ OR HIGH RISK"
            @message = "#{@risk}<br>Advise re-test every 12 months".to_s.html_safe
        elsif @risk.upcase == "HIGH RISK EVENT IN LAST 3 MONTHS"
            @message = "#{@risk}<br>Check event in last 72 hours".to_s.html_safe
        elsif @risk.upcase == "LOW RISK"
            @message = "#{@risk}<br>Patient Negative".to_s.html_safe
        else
            @message = "#{@risk}<br>Re-test in 4 weeks to rule out New infection".to_s.html_safe
        end
    end
       
  end
	
	def referral_consent
					@client = Client.find(params[:id])
	end

  def appointment
			@client = Client.find(params[:id])
  		today = (session[:datetime].to_date rescue Date.today)
  		@start_week_date = today - 1.week
  		@initial_date =  today + 1.day
  		@end_week_date = today + 2.years

  		@waiting_list = nil
  		@waiting_list = true if !params[:waiting_list].blank?

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
      #return if params[:search].blank?
			location = Village.where("name LIKE '%#{params[:search]}%'")
			location = location.map do |locs|
      "#{locs.name}"
    end
    render :text => location.join("\n") and return
	end
	
	def first_name
     #return if params[:search].blank?
			person = PersonName.where("given_name LIKE '%#{params[:search]}%'")
			person = person.map do |locs|
      "#{locs.given_name}"
    end
    render :text => person.join("\n") and return
	end

	def last_name
      #return if params[:search].blank?
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
  end

  def print_new_accession(client_id)
    client = Client.find(client_id)
		print_string = get_accession_label(client)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{client_id}#{rand(10000)}.lbl", :disposition => "inline")
  end

  def print_summary
    client = Client.find(params[:id])
		print_string = get_summary_label(client)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:id]}#{rand(10000)}.lbl", :disposition => "inline")
  end

  def print_confirmation
    client = Client.find(params[:id])
		print_string = get_confirmation_label(client)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:id]}#{rand(10000)}.lbl", :disposition => "inline")
  end

    def get_confirmation_label(client)
    test_type = ConceptName.find_by_name("HIV TEST TYPE").concept_id
    confirmed = Observation.where("concept_id = ? AND person_id = ?", test_type, client.patient_id).order("encounter_id DESC").first rescue []

     label = ZebraPrinter::StandardLabel.new
     label.draw_barcode(300,30,0,1,4,8,50,false,"#{client.accession_number}")
     label.draw_text("#{client.accession_number}",75, 30, 0, 3, 1, 1, false)
     label.draw_line(25,120,800,5)
    if ! confirmed.blank?
          test_result = ConceptName.find_by_name("RESULT OF HIV TEST").concept_id
          result = Observation.where("encounter_id = ? AND concept_id = ?", confirmed.encounter_id, test_result).first.to_s.split(':')[1].squish
          result = "Test Result : #{result}"
          test_location = "Facility name: #{Settings.facility_name}"
          date = "Date: #{Date.today.strftime('%d-%m-%Y')}"
          issued_date = "Issued On: #{(session[:datetime].to_date  rescue Date.today).strftime('%d-%m-%Y')}"
          test_date = "Visit Date: #{confirmed.obs_datetime.strftime('%d/%m/%Y') rescue ''}"
          user = "Confirmed by #{User.find(confirmed.creator).username}"
  
          label.draw_text(test_location,75, 130, 0, 3, 1, 1, false)        
          label.draw_text(result,75, 160, 0, 3, 1, 1, false)
          label.draw_text(user,75, 190, 0, 3, 1, 1, false)
          label.draw_text(test_date,75, 220, 0, 3, 1, 1, false)
    else
       label.draw_text("Never Tested",75, 130, 0, 3, 1, 1, false)
    end
      label.print(1)
    end
    def get_summary_label(client)
    current = session[:datetime].to_date rescue Date.today
    return unless client.patient_id
    coulnsel = "No"
    refer = "No"
    appointment = "No"
    tested = client.tested(current)
    counsel = "Yes" if ! client.counselled(current).blank?
    refer = "Yes" if ! client.referred(current).blank?
     if ! client.appointment(current).blank?
       appointment = "Yes"
       concept = ConceptName.where("name = 'appointment date'").last.concept_id
       encounter = client.appointment(current).encounter_id
       date = Observation.where("concept_id= ? AND encounter_id = ?", concept, encounter).first.to_s.split(':')[1]
     end
    answer = "No"
    answer = "Yes" if ! tested.blank?
    label = ZebraPrinter::StandardLabel.new
   # label.draw_text("#{current.strftime('%d/%m/%Y')}",575, 30, 0, 2, 1, 2, false)
     label.draw_barcode(300,30,0,1,4,8,50,false,"#{client.accession_number}")
    label.draw_line(25,120,800,5)
    label.draw_text("#{client.accession_number}",75, 30, 0, 3, 1, 1, false)
    label.draw_text("Tested : #{answer}",75, 130, 0, 3, 1, 1, false)
    label.draw_text("Counselled : #{counsel}",300, 130, 0, 3, 1, 1, false)
    label.draw_text("Referred : #{refer}",75, 150, 0, 3, 1, 1, false)
    label.draw_text("Appointment : #{appointment}",75, 180, 0, 3, 1, 1, false)
    if appointment == "Yes"
      label.draw_text("  #{date}",300, 180, 0, 3, 1, 1, false)
    end
    label.print(1)

  end

  def get_accession_label(client)
    return unless client.patient_id
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false,"#{client.accession_number rescue ''}")
    label.draw_multi_text("Accession Number     #{client.accession_number}")
    label.print(1)
  end

	def current_visit
		current_date = session[:datetime].to_date rescue Date.today
		@client = Client.find(params[:client_id])
    @show_name = " For #{@client.name.humanize}" if @client.partner_present == true
    @task = next_task(@client)
    if @task["name"]== "Update Status"
       @task["url"] = "/client_status/#{@client.patient_id}?config=couple"
    end
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
    render layout: false
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
			 session[:show_new_client_button] = true
       @occupation = ["Business", "Craftsman","Domestic worker","Driver","Farmer","Health worker",
                      "Housewife","Mechanic","Messenger","Office worker","Police","Preschool child", "Salesperson",
                      "Security guard","Soldier","Student","Teacher","Other","Unknown"]
       @land_mark = ["School","Police","Church","Mosque","Borehole"]
       @reception_demographics = Settings.full_demographics_at_reception
	end
	
	def search_results

		 @show_new_client_button = session[:show_new_client_button] rescue false
		 current_date = session[:datetime].to_date rescue Date.today.to_date
		 identifier_type = ClientIdentifierType.find_by_name("HTC Identifier").id

		 if !params[:accession_number].blank? || !params[:barcode].blank?

				accession = params[:barcode] if  ! params[:barcode].blank?
				accession = params[:accession_number] if ! params[:accession_number].blank?

			  @accession = ClientIdentifier.where("identifier = '#{accession}' 
											AND identifier_type = #{identifier_type} AND voided = 0").last rescue []

				if @accession.blank?
					flash[:notice] = "Invalid accession number..."
					redirect_to "/htcs" and return
				end
				@residence = PersonAddress.find_by_person_id(@accession.patient_id).address1
				@scanned = Client.find(@accession.patient_id)

				if params[:add_to_session] =="true" || !params[:barcode].blank?

					if !@scanned.current_state(current_date).blank? && !@current_location.name.match(/reception/i)
						if @scanned.current_state(current_date).name == "IN WAITING"
						 assign_to_counseling_room(@scanned)
						end
          else
            redirect_to "/clients/confirm/#{@accession.patient_id}" and return if @current_location.name.match(/reception/i)

            flash[:notice] = "Client not on waiting list"
						redirect_to "/search" and return
					end
				end



				if params[:client]
           session[:partner] = @scanned.patient_id
           
           session[:client_id] = params[:client]
           relationship_type = RelationshipType.where("a_is_to_b = 'spouse/partner'").first.relationship_type_id
           @relation = Relationship.where("(person_a = ? AND person_b = ?)
                                                                  OR (person_a = ? AND person_b = ?)",
                                                                  params[:client], @scanned.patient_id, @scanned.patient_id, 
                                                                  params[:client]).order(relationship_id: :desc).first
            if @relation.blank?
               @relation = Relationship.create(person_a: params[:client], person_b: @scanned.patient_id,
                                  relationship: relationship_type, creator: current_user.id)
            end
            concept_id = ConceptName.find_by_name("partner or spouse").concept_id
            answer =  ConceptName.find_by_name("yes").concept_id
            p_session = encounter_done(@scanned.patient_id, 'IN SESSION')
            if ! p_session.blank?
                encounter = p_session.first
            else
                encounter = write_encounter("IN SESSION", @scanned)
            end
            c_session = encounter_done(Client.find(params[:client]), 'IN SESSION').first rescue []
            if c_session.blank?
               c_session = write_encounter("IN SESSION", Client.find(params[:client]))
            end
            
            obs = Observation.create(person_id: encounter.patient_id, concept_id: concept_id,encounter_id: encounter.encounter_id,
                      obs_datetime: encounter.encounter_datetime,
                      creator: current_user.id, value_coded: answer)
             obs = Observation.create(person_id: c_session.patient_id, concept_id: concept_id,encounter_id: c_session.encounter_id,
                      obs_datetime: c_session.encounter_datetime,
                      creator: current_user.id, value_coded: answer)
            
           redirect_to "/couple/status?client_id=#{params[:client]}" and return
        else
           redirect_to "/client_demographics?client_id=#{@scanned.patient_id}" and return
        end
				
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
					
					has_booking = false
					appointment_date = client.has_booking.value_datetime rescue nil
					
					if !appointment_date.blank?
						has_booking = true
						appointment_date = appointment_date.to_date.to_formatted_s(:rfc822)
					end
					
					@clients_info << { id: id, accession: accession,
														 birth: birth, gender: gender, residence: residence}

					@side_panel_date += sp + "#{id} : { id: #{id},
											accession_number: '#{accession}', status: '#{status}',
											age: #{age}, gender: '#{gender}', last_visit: '#{last_visit}',
											birthDate: '#{birth}', residence: '#{residence}',
											days_since_last_visit: '#{days_since_last_visit}',
											has_booking: #{has_booking}, appointment_date: '#{appointment_date}'}"
					sp = ','
				end
				
     end
     render layout: false
	end


  def confirm

    if request.post?
      #Add the confirmed client to waiting list
      add_to_unallocated
    end

    current_date = session[:datetime].to_date rescue Date.today.to_date
    @reception_demographics = Settings.full_demographics_at_reception
    @current_state = @client.current_state(current_date).name rescue nil

    @id = @client.id
    address = PersonAddress.find_by_person_id(@client.id)
    @residence = address.address1
    @ta = address.county_district
    @home_district = address.address2
    type = PersonAttributeType.where("name = 'occupation'").first.id rescue ""
    @occupation = PersonAttribute.where("person_id = ? AND person_attribute_type_id =?", @id, type).first.value rescue ""
    type = PersonAttributeType.where("name = 'Home Phone Number'").first.id rescue ""
    @home_phone_number = PersonAttribute.where("person_id = ? AND person_attribute_type_id =?", @id, type).first.value rescue ""
    type = PersonAttributeType.where("name = 'Office Phone Number'").first.id rescue ""
    @office_phone_number = PersonAttribute.where("person_id = ? AND person_attribute_type_id =?", @id, type).first.value rescue ""
    type = PersonAttributeType.where("name = 'Cell Phone Number'").first.id rescue ""
    @cell_phone_number = PersonAttribute.where("person_id = ? AND person_attribute_type_id =?", @id, type).first.value rescue ""
    type = PersonAttributeType.where("name = 'Landmark Or Plot Number'").first.id rescue ""
    @land_mark = PersonAttribute.where("person_id = ? AND person_attribute_type_id =?", @id, type).first.value rescue ""
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
			
		 has_booking = false
		 appointment_date = c.has_booking.value_datetime rescue nil

		 if appointment_date.blank?
			appointment_date = c.latest_booking.value_datetime rescue nil
		end
		
		 if !appointment_date.blank?
		 	has_booking = true
		 end

		 if appointment_date.blank?
			appointment_date = c.latedst_booking.value_datetime rescue nil
			has_booking = true if !appointment_date.blank?
		 end
			
     @waiting << { id: c.id, accession_number: c.accession_number,
     							  age: c.person.age, gender: c.person.gender,
     							  datetime: datetime, date: date, time: time,
     							  birthDate: birth, address: residence,
     							  days_since_last_visit: days_since_last_visit,
     							  has_booking: has_booking, appointment_date: appointment_date
     							 }
     end
     
     #raise @waiting.to_json 
     @waiting = @waiting.sort!{ |b,a| (a[:appointment_date].to_datetime rescue '1901-01-01'.to_datetime) <=> (b[:appointment_date].to_datetime rescue '1901-01-01'.to_datetime) } rescue []
     
     sp = ""
     @w = ""
     @side_panel_date = ""
     
     order = 0
     
		 @waiting.each do |i|
				appointment_date = i[:appointment_date]
				if !appointment_date.blank?
					appointment_date = appointment_date.to_date.to_formatted_s(:rfc822)
				end
				
				@w += sp + "{ id: #{i[:id]}, accession_number: '#{i[:accession_number]}',
										age: #{i[:age]}, gender: '#{i[:gender]}',
										datetime: '#{i[:datetime].to_s}', date: '#{i[:date]}', 
										time: '#{i[:time]}', birthDate: '#{i[:birthDate]}',
										has_booking: #{i[:has_booking]}, appointment_date: '#{appointment_date}'}"
				

				@side_panel_date += sp + "#{i[:id]} : {order: #{order}, id: #{i[:id]},
										accession_number: '#{i[:accession_number]}',
										age: #{i[:age]}, gender: '#{i[:gender]}',
										datetime: '#{i[:datetime].to_s}', date: '#{i[:date]}', time: '#{i[:time]}',
										birthDate: '#{i[:birthDate]}', residence: '#{(i[:address] || "").humanize}',
										days_since_last_visit: '#{i[:days_since_last_visit]}',
										has_booking: #{i[:has_booking]}, appointment_date: '#{appointment_date}' }"
				order+=1
				sp = ','
			end

     render layout: false
	end
  
  def add_to_unallocated
    write_encounter('IN WAITING', @client)
    redirect_to waiting_list_path
  end
  
  def remove_from_waiting_list
  	date = session[:datetime].to_date rescue Date.today.to_date
  	encounter_type_id = EncounterType.find_by_name('IN WAITING').id
		@client.encounters.where("encounter_type = #{encounter_type_id} AND
															DATE(encounter_datetime) = '#{date}'")
											.each {|e| e.void(reason = "cancelled HTC encounter")}
											
		redirect_to "/clients/appointment?id=" + @client.id.to_s + "&waiting_list=true" and return
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
	
  def total_bookings
    date = params[:date].to_date
    date = Date.today.to_date if date.blank?
    encounter_type = EncounterType.find_by_name('APPOINTMENT')
    concept_id = ConceptName.find_by_name('APPOINTMENT DATE').concept_id

    start_date = date.strftime('%Y-%m-%d 00:00:00')
    end_date = date.strftime('%Y-%m-%d 23:59:59')

    appointments = Observation.find_by_sql("
			SELECT  todays_bookings.*, lastest_encounter_date.encounter_datetime
				FROM (
							SELECT person_id, value_datetime
								FROM obs
								WHERE concept_id = #{concept_id} AND value_datetime >= '#{start_date}' AND value_datetime <= '#{end_date}' AND voided=0) AS todays_bookings
					LEFT JOIN (
							SELECT patient_id, MAX(encounter_datetime) AS encounter_datetime
								FROM encounter
								WHERE voided=0
							GROUP BY patient_id) AS lastest_encounter_date
						ON todays_bookings.person_id=lastest_encounter_date.patient_id
			WHERE todays_bookings.value_datetime > lastest_encounter_date.encounter_datetime
		")
 
    count = appointments.count unless appointments.blank?
    count = '0' if count.blank?

    render :text => (count.to_i >= 0 ? {params[:date] => count}.to_json : 0)
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
