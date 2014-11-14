class CounselorController < ApplicationController
  def test_details
    test_id = TestEncounterType.where(name: "Proficiency Test").first.id
    details = {}
    if params[:user_id]
        proficiency_tests = TestEncounter.where("creator = ? and test_encounter_type = ? and voided = 0",
                                      params[:user_id], test_id ).order(id: :desc)

        proficiency_tests.each{|test|
        details[test.id] = {}
        details[test.id]["date"] = test.encounter_datetime.to_date.strftime("%d/%m/%Y") rescue test.encounter_datetime
        (1..6).each { |int|
                 concept_id = get_id("Sample #{int}")
                 obs_group = TestObservation.where("concept_id = ? and encounter_id = ? and voided = 0",
                                      concept_id, test.id).order(encounter_id: :desc).first.id rescue []
                 details[test.id]["Sample #{int}"] = {}
                 
                 next if obs_group.blank?
                 test_obs = TestObservation.where("obs_group_id = ? and voided = 0", obs_group)
                 test_obs.each{|obs|
                    details[test.id]["Sample #{int}"]["#{get_name(obs.value_group_id)}"] = {} if details[test.id]["Sample #{int}"]["#{get_name(obs.value_group_id)}"].blank?
                    name = get_name(obs.concept_id).upcase
                    if name == "KIT LOT NUMBER"
                      value = obs.value_text
                    elsif name == "EXPIRY DATE"
                      value = obs.value_date.to_date.strftime("%d/%m/%Y") rescue obs.value_date
                    elsif name == "FINAL RESULT" || name == "OFFICIAL RESULT"
                      value = get_name(obs.value_coded) rescue "Invalid"
                    end
                    details[test.id]["Sample #{int}"]["#{get_name(obs.value_group_id)}"]["#{name}"] = value
                 }
                 
                }
        }
    elsif ! params[:encounter_id].blank?

      details["encounter_id"] = params[:encounter_id]
			details["disabled"] = ""
      name = params[:name]

      if name.match(/Sample/i)

         sample = name.split('-')[0].squish
         test = name.split('-')[1].squish

				 obs_sample = TestObservation.where("encounter_id = ? and concept_id = ?
											and voided = 0", params[:encounter_id], get_id(sample)).order(id: :desc).first.id rescue []
				 if ! obs_sample.blank?
						concepts = [{"name" => 'Expiry Date',
                            "storage" => "expiry date",
                            "type" => "value_date"},
                          {"name" => 'Final Result',
                            "storage" => "final result",
                            "type" => "value_coded"},
                          {"name" => 'Kit Lot Number',
                            "storage" => "lot number",
                            "type" => "value_text"},
                          {"name" => 'Official Result',
                            "storage" => "official result",
                            "type" => "value_coded"}]

						value_group = get_id(test)
						concepts.each{|concept|
						
							obs = TestObservation.where("encounter_id = ? AND concept_id = ? 
															and value_group_id = ? and obs_group_id = ? and voided = 0",
											 params[:encounter_id], get_id(concept["name"]), value_group, 
											 obs_sample).order(id: :desc).first[:"#{concept['type']}"] rescue []
							if obs.blank?
								obs = ""
							elsif concept["type"] == "value_coded"
								obs = get_name(obs) rescue "invalid"
							elsif concept["type"] == "value_date"
								obs = obs.strftime("%d/%m/%Y") rescue ""
							end

							details["#{concept["storage"]}"] = obs

						}
						if ! details["official result"].blank?
							details["disabled"] = "disabled"
						else
							details["encounter_id"] = ""
						end
				 end
      else
       concepts = [{"name" => 'Proficiency Test Date',
                      "storage" => "pt date",
                      "type" => "value_date"},
                    {"name" => 'Proficiency Test Panel Lot Number',
                      "storage" => "pt number",
                      "type" => "value_text"}]
        concepts.each{|concept|
            obs = TestObservation.where("encounter_id = ? AND concept_id = ?",
                       params[:encounter_id], get_id(concept["name"])).order(id: :desc).first[:"#{concept['type']}"]

						if concept["type"] == "value_date"
								obs = obs.strftime("%d/%m/%Y") rescue ""
						end

            details["#{concept["storage"]}"] = obs
        }
       end
    else
        user_id = current_user.id
         date = params[:date].to_date
         location = Location.current_location_id

         test = TestEncounter.create(test_encounter_type: test_id, creator: user_id,
                    encounter_datetime: date, location_id: location, voided: 0).id
        details["pt number"] = params[:lot_number]
        details["pt date"] = params[:date]
         concepts = [{"name" => 'Proficiency Test Date',
                                "value" => date,
                                "type" => "value_date"},
                              {"name" => 'Proficiency Test Panel Lot Number',
                                "value" => params[:lot_number],
                                "type" => "value_text"}]

         concepts.each{|concept|
            concept_id = ConceptName.where(name: concept["name"]).first.concept_id
            test_obs = TestObservation.create(encounter_id: test, concept_id: concept_id,
                              concept['type'] => concept['value'], location_id: location, obs_datetime: date, voided: 0 )
         }
         details["encounter_id"] = test
    end
    render text: details.to_json
  end

  def list_tests
    @session_date = session[:datetime].to_date rescue Date.today

    @cur_month = @session_date.strftime("%B")
    @cur_year = @session_date.year

    @user = current_user
    @users = User.find_by_sql("select * from users
                    inner join user_role on users.user_id = user_role.user_id")

    @site_name = Settings.facility_name

    @years = []
    i = @session_date.year
    min = User.find_by_sql("SELECT min(date_created) e FROM users LIMIT 1")[0][:e].to_date.year - 1  rescue (Date.today.year - 1)
    while (i >= min)
 	    @years << i
	    i -= 1
    end
    @years.reverse!

    render layout: false
  end

  def sample
      @encounter = TestEncounter.find(params[:encounter_id])
      @counselor = User.find(@encounter.creator)
      
       @kits, @remaining, @testing = Kit.kits_available(current_user)
      # raise @kits[0][1].to_yaml
      @tests = ["Test 1", "Test 2", "Test 3", "Official Result"]
  end

  def final_result
    sample = params[:sample].split("-")[0].squish
    test = params[:sample].split("-")[1].squish
    details = {}

		encounter = TestEncounter.find(params[:encounter_id])

		obs_group = TestObservation.where("concept_id = ? AND encounter_id = ?",
				                 get_id(sample), params[:encounter_id]).first #rescue []

		if ! params[:official_result].blank?
				details["official result"] = ""
				unless obs_group.blank?
					obs = TestObservation.create(encounter_id: params[:encounter_id], concept_id: get_id("Official result"),
				                        obs_datetime: encounter.encounter_datetime, voided: 0, 
																value_coded:  get_id(params[:official_result]), value_group_id: get_id(test), 
																obs_group_id: obs_group.id)
					details["official result"] = params[:official_result]
					details["disabled"] = "disabled"
				end
		else

				details["lot number"] = params[:lot_number]
				details["final result"] = params[:result]
				details["expiry date"] = params[:date]

				values = [["Expiry Date",params[:date].to_date],["Final Result", params[:result]]]
				
				if obs_group.blank?
					obs_group = TestObservation.create(encounter_id: params[:encounter_id], concept_id: get_id(sample),
								        obs_datetime: encounter.encounter_datetime, voided: 0)
				end

				concepts = [{"name" => 'Expiry Date',
				                        "value" => params[:date],
				                        "type" => "value_date"},
				                      {"name" => 'Final Result',
				                        "value" => params[:result],
				                        "type" => "value_coded"},
				                      {"name" => 'Kit Lot Number',
				                        "value" => params[:lot_number],
				                        "type" => "value_text"}]

				concepts.each{|concept|
				    if concept['type'] == "Final Result"
				      concept['value'] = get_id(params[:result])
				    end
				    obs = TestObservation.create(encounter_id: params[:encounter_id], concept_id: get_id(concept["name"]),
				                        obs_datetime: encounter.encounter_datetime, voided: 0, 
																concept['type'] => concept['value'], value_group_id: get_id(test), 
																obs_group_id: obs_group.id)
				}

		end

    render text: details.to_json
  end

  def get_id(concept)
    concept_id = ConceptName.where(name: concept).first.concept_id
  end

  def get_name(concept)
    concept_name = ConceptName.find(concept).name
  end
end
