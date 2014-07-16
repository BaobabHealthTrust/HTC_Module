class EncountersController < ApplicationController
 # before_action :set_encounter, only: [:show, :edit, :update, :destroy]

  def index
    @encounters = Encounter.all
  end

  def show
  end

  def new
		current = session[:datetime].to_date rescue Date.today
		person = Person.find(params[:id])
		encounter = write_encounter(params["ENCOUNTER"], person, current)
		
		if params["ENCOUNTER"].upcase == "COUNSELING"
			  params[:obs].each do |key, value|
					 
				end
		end
		redirect_to "/clients/#{params[:id]}" and return
  end

  def edit
  end

  def create
    @encounter = Encounter.new(encounter_params)
      if @encounter.save
      else
      end
  end

  def update

    if @encounter.update(encounter_params)

    else

    end

  end

  def destroy
    @encounter.destroy
  end

	def write_encounter(encounter_type, person, current = Date.today)		
			type = EncounterType.find_by_name(encounter_type).id
			encounter = Encounter.create(encounter_type: type, patient_id: person.id, location_id: current_location.id,
									encounter_datetime: current, creator: current_user.id)
			return encounter.encounter_id		
	end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_encounter
      @encounter = Encounter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def encounter_params
      params[:encounter]
    end
end
