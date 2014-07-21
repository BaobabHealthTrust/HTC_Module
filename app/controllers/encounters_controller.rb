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
					 concept_id = ConceptName.find_by_name(value).concept_id
					 answer = CounselingAnswer.create(question_id: key, patient_id: person.id,
									  encounter_id: encounter, value_coded: concept_id, 
									  creator: current_user.id)
				end
		end
		
    (params[:observations] || []).each do |observation|

              next if observation[:concept_name].blank?

              # Check to see if any values are part of this observation
              # This keeps us from saving empty observations
              values = ['coded_or_text', 'coded_or_text_multiple', 'group_id', 'boolean', 'coded', 'drug', 'datetime', 'numeric', 'modifier', 'text'].map{|value_name|
                observation["value_#{value_name}"] unless observation["value_#{value_name}"].blank? rescue nil
              }.compact

              next if values.length == 0

              observation[:value_text] = observation[:value_text].join(", ") if observation[:value_text].present? && observation[:value_text].is_a?(Array)
              observation.delete(:value_text) unless observation[:value_coded_or_text].blank?
							
							observation[:obs_datetime] = current
							observation[:creator] = current_user.id
              observation[:encounter_id] = encounter.id
              # observation[:obs_datetime] = encounter.encounter_datetime || Time.now()
              observation[:person_id] ||= encounter.patient_id
              
              # Handle multiple select
              if observation[:value_coded_or_text_multiple] && observation[:value_coded_or_text_multiple].is_a?(Array)
                observation[:value_coded_or_text_multiple].compact!
                observation[:value_coded_or_text_multiple].reject!{|value| value.blank?}
              end
              if observation[:value_coded_or_text_multiple] && observation[:value_coded_or_text_multiple].is_a?(Array) && !observation[:value_coded_or_text_multiple].blank?
                values = observation.delete(:value_coded_or_text_multiple)
                values.each{|value| observation[:value_coded_or_text] = value; Observation.create(observation) }
              else
								#raise observation.to_yaml
                observation.delete(:value_coded_or_text_multiple)
                Observation.create(observation) rescue []
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
			return encounter		
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
