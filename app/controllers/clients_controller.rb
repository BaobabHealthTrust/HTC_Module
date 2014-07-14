class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy,
                                    :add_to_unallocated]

  def index
    @clients = Client.all
  end

  def show
			current_date = session[:datetime].to_date rescue Date.today
		  identifier_type = ClientIdentifierType.find_by_name("HTC Identifier").id
			@accession_number = ClientIdentifier.find(:last, 
																	 :conditions => ["identifier_type = ? AND patient_id = ?", 
																		identifier_type, @client.id]).identifier rescue ""
			@residence = PersonAddress.find_by_person_id(@client.id).address1
			@names = PersonName.find_by_person_id(@client.id)
			person = Person.find(@client.id)
			@age = person.age(current_date)
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
			type = type.identifier.split(" ")[0].to_i rescue 0
			identifier = current_number + type
			
			@person = Person.create(gender: params[:gender], birthdate: params[:dob], creator: current_user.id)
    	@client = Client.create(patient_id: @person.person_id, creator: current_user.id) if @person
			@address = PersonAddress.create(person_id: @person.person_id, 
															address1: params[:residence], creator: current_user.id) if @person
			@identifier = ClientIdentifier.create(identifier_type: identifier_type, 
															patient_id: @client.id, 
															identifier: "#{identifier} #{current.year}", creator: current_user.id)
			write_encounter("UNALLOCATED", @person, current)

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
				
	end

	def testing
  		
  end

	def current_visit
	
	end
	
  def previous_visit

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
		 if ! params[:accession_number].blank?
			  @accession = ClientIdentifier.where("identifier = '#{params[:accession_number]}' 
											AND identifier_type = #{identifier_type} AND voided = 0").last rescue []
				if @accession.blank?
					flash[:notice] = "Invalid accession number...."
					redirect_to "/search" and return
				end
				@residence = PersonAddress.find_by_person_id(@accession.patient_id).address1
				@scanned = Client.find(@accession.patient_id)
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
	end
	
	def unallocated_clients
     encounter_type_id = EncounterType.find_by_name('Unallocated').id
		 @clients = Client.joins(:encounters)
                      .where("encounter_type = #{encounter_type_id} AND
                              DATE(encounter_datetime) = '#{Date.today}'")
	end
  
  def add_to_unallocated
    write_encounter('Unallocated', @client)

    redirect_to unallocated_clients_path 
  end

	def write_encounter(encounter_type, person, current = Date.today)		
			type = EncounterType.find_by_name(encounter_type).id
			encounter = Encounter.create(encounter_type: type, patient_id: person.id, location_id: current_location.id,
									encounter_datetime: current, creator: current_user.id)		
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
