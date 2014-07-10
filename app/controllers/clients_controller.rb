class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = Client.all
  end

  def show
  end

  def new
		if ! params[:gender].blank? and ! params[:dob].blank?
			current_number = 1
			current_year = session[:datetime].to_date.year.to_s rescue Date.today.year.to_s
			identifier_type = ClientIdentifierType.find_by_name("HTC Identifier").id
			type = ClientIdentifier.find(:last, 
																	 :conditions => ["identifier_type LIKE ?
																		AND voided = 0", '%#{current_year}'])
			type = type.identifier.split(" ")[0] rescue 0
			identifier = current_number + type

			@person = Person.create(gender: params[:gender], birthdate: params[:dob])
    	@client = Client.create(patient_id: @person.person_id) if @person
			@address = PersonAddress.create(person_id: @person.person_id, 
															address1: params[:residence]) if @person

			patient_identifier = ClientIdentifier.new
      patient_identifier.identifier_type = identifier_type
      patient_identifier.identifier =  "#{identifier} #{current_year}"
      patient_identifier.patient_id = @client.id
      patient_identifier.save!
			#@identifier = ClientIdentifier.create(identifier_type: identifier_type, 
			#												patient_id: @client.id, 
			#												identifier: "#{identifier} #{current_year}")

		end
		redirect_to action: 'search_results', residence: @address.address1, gender: @person.gender, date_of_birth: @person.birthdate
  end

  def edit
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
		 @clients = Client.find_by_sql("SELECT * FROM patient p
											INNER JOIN person pe ON pe.person_id = p.patient_id 
											INNER JOIN person_address pn ON pn.person_id = pe.person_id
											WHERE pn.address1 = '#{params[:residence]}' AND pe.gender = '#{params[:gender]}'
											AND DATE(pe.birthdate) = '#{params[:date_of_birth].to_date}' AND p.voided = 0 AND
											pn.voided = 0 LIMIT 20") rescue []
	end
	
	def unallocated_clients
		 @clients = Client.all(:limit=>20)
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
