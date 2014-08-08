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
		encounter = write_encounter(params["ENCOUNTER"], person)
		#raise params.to_yaml
		if params["ENCOUNTER"].upcase == "COUNSELING"
			  params[:obs].each do |key, value|
					 type = CounselingQuestion.find(key).data_type rescue []
					 next if type.blank?
					 concept_id = nil
					 value_datetime = nil
					 value_text = nil 
				   value_numeric = nil
					 if type.upcase == "BOOLEAN"
							concept_id = ConceptName.find_by_name(value).concept_id rescue nil
							value_text = value if concept_id.blank?
					 elsif type.upcase == "DATETIME"
							value_datetime = value
					 elsif type.upcase == "NUMBER"
							value_numeric = value
					 elsif type.upcase == "TEXT"
							value_text = value
					 elsif type.upcase == "TIME"
							value_text = value					
					 end
					 
					 answer = CounselingAnswer.create(question_id: key, patient_id: person.id,
									  encounter_id: encounter.encounter_id, value_coded: concept_id, 
									  creator: current_user.id, value_text: value_text, value_numeric: value_numeric,
										value_datetime: value_datetime)
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

	def write_encounter(encounter_type, person, current = DateTime.now)		
			type = EncounterType.find_by_name(encounter_type).id
			encounter = Encounter.create(encounter_type: type, patient_id: person.id, location_id: current_location.id,
									encounter_datetime: current, creator: current_user.id)
			return encounter		
	end

	def observations
		# We could eventually include more here, maybe using a scope with includes
		encounter = Encounter.find(params[:id], :include => [:observations])
		@child_obs = {}
		@observations = []
		encounter.observations.map do |obs|
			next if !obs.obs_group_id.blank?
			if ConceptName.find_by_concept_id(obs.concept_id).name.match(/location/)
				obs.value_numeric = ""
				@observations << obs
			else
				@observations << obs
			end
			child_obs = Observation.where("obs_group_id = ?", obs.obs_id)
			if child_obs
				@child_obs[obs.obs_id] = child_obs
			end
		end
		 ( encounter.counseling_answer || []).each {| answer|
					@observations << answer			
			}
		render :layout => false
	end

	def void
		@encounter = Encounter.find(params[:id])

		@encounter.void
  
		head :ok
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
