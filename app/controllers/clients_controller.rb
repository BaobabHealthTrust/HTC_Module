class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy,
                                    :add_to_unallocated, :remove_from_waiting_list,
                                    :assign_to_counseling_room]

	skip_before_action :village

  def index
    #@clients = Client.all
  end

  def show
			current_date = session[:datetime].to_date rescue Date.today
			@accession_number = @client.accession_number
			@residence = PersonAddress.find_by_person_id(@client.id).address1
			@names = PersonName.find_by_person_id(@client.id)
			person = Person.find(@client.id)
			@status  = @client.current_state 
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
			
			@person = Person.create(gender: params[:gender], birthdate: params[:dob], creator: current_user.id)
    	@client = Client.create(patient_id: @person.person_id, creator: current_user.id) if @person
			@address = PersonAddress.create(person_id: @person.person_id, 
															address1: params[:residence], creator: current_user.id) if @person
			@identifier = ClientIdentifier.create(identifier_type: identifier_type, 
															patient_id: @client.id, 
															identifier: "#{identifier}-#{current.year}", creator: current_user.id)
			write_encounter("IN WAITING", @person, current)

		end
		
		redirect_to action: 'search_results', residence: @address.address1, 
											gender: @person.gender, date_of_birth: @person.birthdate
  end

  def edit
  end

	def demographics
		 		@client = Client.find(params[:client_id])
		 		@residence = PersonAddress.find_by_person_id(@client.id).address1
	end

	def counseling
			@client = Client.find(params[:client_id])
			@protocols = CounselingQuestion.where("retired = 0")	
	end

	def testing
  		@client = Client.find(params[:client_id])
  end
	
	def referral_consent
			
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

	def current_visit
		@client = Client.find(params[:client_id])
		@status  = @client.current_state rescue "NaN"
		@firststatus  = @client.first_state rescue []
		@finalstatus = @client.final_state
		current_date = session[:datetime].to_date rescue Date.today
		@encounters = Encounter.where("encounter.voided = ? and patient_id = ? and encounter.encounter_datetime >= ? and encounter.encounter_datetime <= ?", 0, params[:client_id], current_date.strftime("%Y-%m-%d 00:00:00"), current_date.strftime("%Y-%m-%d 23:59:59")).includes(:observations).includes(:counseling_answer).order("encounter.encounter_datetime DESC")
				@creator_name = {}
    @encounters.each do |encounter|
      id = encounter.creator
      user_name = User.find(id).person.names.first
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
		 identifier_type = ClientIdentifierType.find_by_name("HTC Identifier").id
		 if ! params[:accession_number].blank? || ! params[:barcode].blank?
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
				
				if params[:add_to_session] =="true"
					 assign_to_counseling_room(@scanned)
				end
				
				redirect_to "/clients/#{@scanned.patient_id}" and return
		 else
		 		@clients = Client.find_by_sql("SELECT * FROM patient p
											INNER JOIN person pe ON pe.person_id = p.patient_id 
											INNER JOIN person_address pn ON pn.person_id = pe.person_id
											LEFT JOIN patient_identifier pi ON pi.patient_id = p.patient_id
											WHERE pn.address1 = '#{params[:residence]}' AND pe.gender = '#{params[:gender]}'
											AND DATE(pe.birthdate) = '#{params[:date_of_birth].to_date}' AND p.voided = 0
											AND pi.identifier_type = #{identifier_type} AND pi.voided = 0 AND
											pn.voided = 0 ORDER BY pi.identifier DESC LIMIT 20") rescue []
     end
     render layout: false
	end
	
	def waiting_list
     encounter_type_id = EncounterType.find_by_name('IN WAITING').id
		 @clients = Client.joins(:encounters)
                      .where("encounter_type = #{encounter_type_id} AND
                              DATE(encounter_datetime) = '#{Date.today}'")
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
			type = EncounterType.find_by_name(encounter_type).id
			encounter = Encounter.create(encounter_type: type, patient_id: person.id,
									location_id: current_location.id, encounter_datetime: current,
									creator: current_user.id)
	end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params[:client]
    end
end
