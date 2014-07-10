class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = Client.all
  end

  def show
  end

  def new
		if ! params[:gender].blank? and ! params[:dob].blank?
			@person = Person.create(gender: params[:gender], birthdate: params[:dob])
    	@client = Client.create(patient_id: @person.person_id) if @person
			@address = PersonAddress.create(person_id: @person.person_id, address1: params[:residence]) if @person
		end
		redirect_to action: 'search_results'
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
											AND DATE(pe.birthdate) = '#{params[:date_of_birth].to_date}' AND p.voided = 0 AND pn.voided = 0 
											LIMIT 20")
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
