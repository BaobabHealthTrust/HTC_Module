class EncountersController < ApplicationController
 # before_action :set_encounter, only: [:show, :edit, :update, :destroy]

  def index
    @encounters = Encounter.all
  end

  def show
  end

  def new
#raise params.to_yaml
		current = session[:datetime].to_datetime rescue DateTime.now
		person = Person.find(params[:id])
    patient = Client.find(params[:id])
		encounter = write_encounter(params["ENCOUNTER"], person)

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
              if value.match(/\?/)
                value_text = value
                value_datetime = nil
              end
					 elsif type.upcase == "NUMBER"
							value_numeric = value
					 elsif type.upcase == "TEXT"
							value_text = value
					 elsif type.upcase == "TIME"
							value_text = value	
					 elsif type.upcase == "LIST"
							value_text = value					
					 end
					 
					 answer = CounselingAnswer.create(question_id: key, patient_id: person.id,
									  encounter_id: encounter.encounter_id, value_coded: concept_id, 
									  creator: current_user.id, value_text: value_text, value_numeric: value_numeric,
										value_datetime: value_datetime)
				end
		end 

    test_kit = {}
    (params[:observations] || []).each do |observation|

              next if observation[:concept_name].blank?

              if params["ENCOUNTER"].upcase == "HIV TESTING"
                  (1..2).each{|i|
                     if observation[:concept_name] ==  "HTC Test #{i} name"
                        used = CouncillorInventory.create_used_testkit(observation[:value_text], params["test#{i} done"], current, current_user)
                     end
                  }
              end
              # Check to see if any values are part of this observation
              # This keeps us from saving empty observations
              if params["ENCOUNTER"].upcase == "UPDATE HIV STATUS"  and observation[:concept_name].upcase == "PATIENT PREGNANT"
                    observation[:value_coded_or_text] = params[:patient]
              end

              if !observation["value_datetime"].blank?
                 if observation["value_datetime"].match(/\?/)
                    observation["value_text"] = observation["value_datetime"]
                    observation["value_datetime"] = nil

                 else
              		observation["value_datetime"] = observation["value_datetime"].to_time.strftime("%Y-%m-%d %H:%M:%S")
                 end
              end
              
              values = ['coded_or_text', 'coded_or_text_multiple', 'group_id', 'boolean', 'coded', 'drug', 'datetime', 'numeric', 'modifier', 'text', 'complex'].map{|value_name|
                observation["value_#{value_name}"] unless observation["value_#{value_name}"].blank? rescue nil
              }.compact

              next if values.length == 0

              observation[:value_text] = observation[:value_text].join(", ") if observation[:value_text].present? && observation[:value_text].is_a?(Array)
              observation.delete(:value_text) unless observation[:value_coded_or_text].blank?

							observation[:obs_datetime] = current.strftime("%Y-%m-%d %H:%M:%S")
							observation[:creator] = current_user.id
              observation[:encounter_id] = encounter.id
              observation[:date_created] = DateTime.now.to_datetime.strftime("%Y-%m-%d %H:%M:%S")
              # observation[:obs_datetime] = encounter.encounter_datetime || Time.now()
              observation[:person_id] ||= encounter.patient_id
              
              # Handle multiple select
              if observation[:value_coded_or_text_multiple] && observation[:value_coded_or_text_multiple].is_a?(Array)
                observation[:value_coded_or_text_multiple].compact!
                observation[:value_coded_or_text_multiple].reject!{|value| value.blank?}
              end
              if observation[:value_coded_or_text_multiple] && observation[:value_coded_or_text_multiple].is_a?(Array) && !observation[:value_coded_or_text_multiple].blank?
                values = observation.delete(:value_coded_or_text_multiple)
                values.each{|value| observation[:value_coded_or_text] = value; Observation.create(observation);}
              else
                observation.delete(:value_coded_or_text_multiple)
                Observation.create(observation) rescue []
              end
              
            end
    if params["ENCOUNTER"].upcase == "APPOINTMENT" && !params[:waiting_list].blank?
    		redirect_to waiting_list_path and return
    end

    unless params["all timers request"].blank?
        if params["all timers request"].upcase == "YES"
            redirect_to  "/extended_testing/#{person.person_id}" and return
        end
    end

    redirect_to next_task(patient)["url"] and return

  end

  def edit
  end

  def create_inventory(name, lot_number)
     
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

	def write_encounter(encounter_type, person)      
			current = session[:datetime].to_datetime.strftime("%Y-%m-%d %H:%M:%S") rescue Time.now.strftime("%Y-%m-%d %H:%M:%S")
			current_location = @current_location if current_location.nil?	
			type = EncounterType.find_by_name(encounter_type).id
			encounter = Encounter.create(encounter_type: type, patient_id: person.id,
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
			child_obs = ObservDation.where("obs_group_id = ?", obs.obs_id)
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
    (Observation.where("encounter_id = ?", params[:id]) || []).each { |obs|
        obs.void
    }
    (CounselingAnswer.where("encounter_id = ?", params[:id]) || []).each{|answer|
       answer.voided = 1
       answer.voided_by = current_user.id
       answer.save
    }
		render :text => "ok"
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
