class CounselorController < ApplicationController
  @@males = ""
  @@preg_females = ""
  @@non_preg_females = ""
  @@age_a = ""
  @@age_b = ""
  @@age_d = ""
  @@ids = []

  def test_details
    test_id = TestEncounterType.where(name: "Proficiency Test").first.id
    details = {}
    if params[:user_id]
				if params[:month]
        start_day, end_day = build_date(params[:month], params[:year])
        proficiency_tests = TestEncounter.where("creator = ? and test_encounter_type = ? and voided = 0 
														AND DATE(encounter_datetime) >= ? AND  DATE(encounter_datetime) <= ?",
                                      params[:user_id], test_id, start_day, end_day ).order(id: :desc)
        #raise "here"
				else
				 proficiency_tests = TestEncounter.where("creator = ? and test_encounter_type = ? and voided = 0",
                                      params[:user_id], test_id ).order(id: :desc)
				end

        proficiency_tests.each{|test|
        details[test.id] = {}
        details[test.id]["date"] = test.encounter_datetime.to_date.strftime("%d/%m/%Y") rescue test.encounter_datetime
        (1..6).each { |int|
                 concept_id = get_id("Sample #{int}")
                 obs_group = TestObservation.where("concept_id = ? and encounter_id = ? and voided = 0",
                                      concept_id, test.id).order(encounter_id: :desc).first.id rescue []
                 details[test.id]["Sample #{int}"] = {}
                concept =  "Sample #{int}"
                 next if obs_group.blank?
                 test_obs = TestObservation.where("obs_group_id = ? and voided = 0", obs_group)
                 test_obs.each{|obs|
                    details[test.id]["Sample #{int}"]["#{get_name(obs.value_group_id)}"] = {} if details[test.id]["Sample #{int}"]["#{get_name(obs.value_group_id)}"].blank?
                    name = get_name(obs.concept_id).upcase
                    if name == "KIT LOT NUMBER"
                      value = obs.value_text
                    elsif name == "EXPIRY DATE"
                      value = obs.value_date.to_date.strftime("%d/%m/%Y") rescue obs.value_date
                    elsif name == "LAB TEST RESULT"
                      value = get_name(obs.value_coded) rescue "Invalid"
                    end
                    details[test.id]["Sample #{int}"]["#{get_name(obs.value_group_id)}"]["#{name.humanize}"] = value
                 }

                  name = ["OFFICIAL RESULT", "FINAL RESULT"]
                  
                  lot = TestObservation.where("concept_id = ? and encounter_id = ? and voided = 0",
                          get_id("Proficiency Test Panel Lot Number"), test.id).take.value_text rescue ""
                  details[test.id]["Sample #{int}"]["resulsts"] = {}
                  name.each{|n|
                      official = TestObservation.where("voided = 0 and concept_id = ? and value_group_id = ? and  value_text = ?",
                      get_id(n), get_id(concept), "#{lot}" ).first.value_coded rescue ""
                      value = get_name(official) rescue "Not available"
                       details[test.id]["Sample #{int}"]["resulsts"]["#{n.humanize}"] = value
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
         details["expiry date"] = ""
         details["final result"] = ""
         details["lot number"] = ""
         details["official result"] = ""
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
											 obs_sample).order(id: :desc).first[:"#{concept['type']}"] rescue ""
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
        test = TestObservation.where("concept_id = ? AND value_text = ? AND DATE(obs_datetime) = ? AND voided = 0",
                                   get_id("Proficiency Test Panel Lot Number"), params[:lot_number],
                                   date.strftime('%Y-%m-%d')).first.encounter_id rescue []

      details["pt number"] = params[:lot_number]
      details["pt date"] = params[:date]
         if is_supervisor
                if test.blank?
                  details["error"] = ""
                 test = TestEncounter.create(test_encounter_type: test_id, creator: user_id,
                            encounter_datetime: date, location_id: location, voided: 0).id

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
                  else
                     details["error"] = "Test found created"
                  end
         else
              
               if ! test.blank?
                  details["error"] = ""
                 test = TestEncounter.create(test_encounter_type: test_id, creator: user_id,
                            encounter_datetime: date, location_id: location, voided: 0).id

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
                  else
                     details["error"] = "No test with entered details"
                  end
         end
         details["encounter_id"] = test
    end
    render text: details.to_json
  end

  def list_tests
    @session_date = session[:datetime].to_date rescue Date.today

    @cur_month = @session_date.strftime("%B")[0,3]
    
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

    
		if test.upcase == "OFFICIAL RESULT" || test.upcase == "FINAL RESULT"
          lot = TestObservation.where("concept_id = ? and encounter_id = ? and voided = 0",
                          get_id("Proficiency Test Panel Lot Number"), encounter.id).take.value_text rescue ""

         result = params[:official_result] if ! params[:official_result].blank?
         result = params[:final_result] if ! params[:final_result].blank?
         details["error"] = ""
				 
					obs = TestObservation.create(encounter_id: params[:encounter_id], concept_id: get_id(test),
				                        obs_datetime: encounter.encounter_datetime, voided: 0, 
																value_coded:  get_id(result), value_group_id: get_id(sample),
                                value_text: lot)
          
					details["official result"] = params[:official_result]
          details["final result"] = params[:final_result]
					details["disabled"] = "disabled"
				
		else
				details["lot number"] = params[:lot_number]
				details["final result"] = params[:result]
        details["result"] = params[:result]
				details["expiry date"] = params[:date]
				
				if obs_group.blank?
					obs_group = TestObservation.create(encounter_id: params[:encounter_id], concept_id: get_id(sample),
								        obs_datetime: encounter.encounter_datetime, voided: 0)
				end

				concepts = [{"name" => 'Expiry Date',
				                        "value" => params[:date],
				                        "type" => "value_date"},
				                      {"name" => 'Lab test result',
				                        "value" => params[:result],
				                        "type" => "value_coded"},
				                      {"name" => 'Kit Lot Number',
				                        "value" => params[:lot_number],
				                        "type" => "value_text"}]

				concepts.each{|concept|
				    if concept['name'] == "Lab test result"
				      concept['value'] = get_id(params[:result])
				    end

            obs = TestObservation.where("encounter_id = ? AND concept_id = ? AND
                      value_group_id = ? AND obs_group_id = ? AND voided = 0", params[:encounter_id],get_id(concept["name"]),
                      get_id(test), obs_group.id).order(id: :desc).first rescue []
                  
            if ! obs.blank?
                obs[:"#{concept['type']}"] = concept['value']
                obs.save!
            else

                obs = TestObservation.create(encounter_id: params[:encounter_id], concept_id: get_id(concept["name"]),
                                    obs_datetime: encounter.encounter_datetime, voided: 0,
                                    concept['type'] => concept['value'], value_group_id: get_id(test),
                                    obs_group_id: obs_group.id)
            end
				}

		end

    render text: details.to_json
  end

  def monthly_details
    details = {}
    start_day, end_day = build_date(params[:month], params[:year])

    cats = {"Sex and Pregnancy" => [["2", "Males Tested",get_value(2, "monthly", start_day, end_day).length],["3","Females (Non-Pregnant) Tested",get_value(3, "monthly", start_day, end_day).length],["4","Females (Pregnant) Tested",get_value(4, "monthly", start_day, end_day).length],
                ["4a","Total Tested",get_value("4a", "monthly", start_day, end_day)],["4b","Percent Males",get_value("4b", "monthly", start_day, end_day)]],
            "Age Group" => [["5","Age group A (0-11 Months)", get_value("5", "monthly", start_day, end_day)],["5a","Male", get_value("5a", "monthly", start_day, end_day)],
              ["5b","Female", get_value("5b", "monthly", start_day, end_day)],["6", "Age group B (12m - 14 years)",get_value("6", "monthly", start_day, end_day)],["6a", "Male",get_value("6a", "monthly", start_day, end_day)],
              ["6b", "Female",get_value("6b", "monthly", start_day, end_day)],
              ["7","Age group C (15 - 24 years)",get_value("7", "monthly", start_day, end_day)],
              ["7a","Male",get_value("7a", "monthly", start_day, end_day)],
              ["7b","Female",get_value("7b", "monthly", start_day, end_day)],
              ["8","Age group D (25+years)",get_value("8", "monthly", start_day, end_day)],
              ["8a","Male",get_value("8a", "monthly", start_day, end_day)],
              ["8b","Female",get_value("8b", "monthly", start_day, end_day)],
              ["9a","Proportion Age Group C",get_value("9a", "monthly", start_day, end_day) ]],
            "HTC Access Type" => [["9","PITC (Routine HTC within Health Service)", get_value("9", "monthly", start_day, end_day)],
              ["10","FRS (Comes with HTC Family Referral Slip)",get_value("10", "monthly", start_day, end_day)],
              ["11","Other (VCT, etc)",get_value("11", "monthly", start_day, end_day)],
            ["12", "Proportion of PITC",get_value("12", "monthly", start_day, end_day)]
            ], "Partner Present" => [["14","Individuals Counselled with Partner",get_value("14", "monthly", start_day, end_day)]],
            "Last HIV Test" => [["15","Never Tested",get_value("15", "monthly", start_day, end_day)],["16","Last Negative",get_value("16", "monthly", start_day, end_day)],
              ["17","Last Positive",get_value("17", "monthly", start_day, end_day)],
              ["18","Last Exposed Infant",get_value("18", "monthly", start_day, end_day)],["19a","Last Inconclusive",get_value("19a", "monthly", start_day, end_day)],["19b","Proportion First Time Clients",get_value("19b", "monthly", start_day, end_day)]],
            "Test Kit Results" => [["21","Single Test Negative",get_value("21", "monthly", start_day, end_day)],
              ["22","Single Test Positive",get_value("22", "monthly", start_day, end_day)],
              ["23","Test 1&2 Negative",get_value("23", "monthly", start_day, end_day)],
              ["24","Test 1&2 Positive",get_value("24", "monthly", start_day, end_day)],
              ["25","Test 1&2 Discordant",get_value("25", "monthly", start_day, end_day)],
              ["26","Proportion Discordant",get_value("26", "monthly", start_day, end_day)]],
            "Results to Client" => [["27","New Negative",get_value("27", "monthly", start_day, end_day)],
              ["28","New Positive",get_value("28", "monthly", start_day, end_day)],
              ["29","New Exposed",get_value("29", "monthly", start_day, end_day)],
              ["30","Confirmatory - Positive",get_value("30", "monthly", start_day, end_day)],
              ["31","New Inconclusive", get_value("31", "monthly", start_day, end_day)],
              ["32","Confirmatory - Inconclusive",get_value("32", "monthly", start_day, end_day)],
              ["33a","Proportion Positive",get_value("33a", "monthly", start_day, end_day)]],
            "Partner HIV Status" => [["34","No Partner",get_value("34", "monthly", start_day, end_day)],
              ["35","HIV Unknown",get_value("35", "monthly", start_day, end_day)],
              ["36","Partner Never",get_value("36", "monthly", start_day, end_day)],
              ["37","Partner Positive",get_value("37", "monthly", start_day, end_day)],
              ["38","Proportion with Partner Unknown HIV Status",get_value("38", "monthly", start_day, end_day)]],
            "Client Risk Category" => [["40","Low Risk",get_value("40", "monthly", start_day, end_day)],
              ["41","On-going Risk",get_value("41", "monthly", start_day, end_day)]]
            }

    render text: cats.to_json
  end

  def moh_details

      result = []

      months = params[:month].split(",") rescue []

      if months.length == 1
        start_day, end_day = build_date(months[0], params[:year])
        result = moh_details_per_month(start_day, end_day)
      else

        months.each do |month|
          start_day, end_day = build_date(month, params[:year])
          result << moh_details_per_month(start_day, end_day)
        end
      end

      render text: result.to_json
  end

  def moh_details_per_month(start_day, end_day)
    details = {}
    details["Sex / Pregnancy"] = [["1", "Male",get_value(2, "monthly", start_day, end_day).length],
                                  ["2","Female Non-Pregnant",get_value(3, "monthly", start_day, end_day).length],
                                  ["3","Female Pregnant",get_value(4, "monthly", start_day, end_day).length]]
    details["Last HIV Test"] = [["13", "Never Tested",get_value("15", "monthly", start_day, end_day)],
                                ["14","Prev Negative",get_value("16", "monthly", start_day, end_day)],
                                ["15","Prev Positive",get_value("17", "monthly", start_day, end_day)],
                                ["16","Prev Exposed infant",get_value("18", "monthly", start_day, end_day)],
                                ["17","Prev Inconclusive",get_value("19a", "monthly", start_day, end_day)]]
    details["Outcome Summary (HIV Test)"] = [["22","Single negative",get_value("21", "monthly", start_day, end_day)],
                                             ["23","Single Positive",get_value("22", "monthly", start_day, end_day)],
                                             ["24","Test 1&2 negative",get_value("23", "monthly", start_day, end_day)],
                                             ["25","Test 1&2 positive",get_value("24", "monthly", start_day, end_day)],
                                             ["26","Test 1&2 discodant",get_value("25", "monthly", start_day, end_day)]]
    details["Age groups"] = {}
    details["Age groups"]["Sections 1"] = ["M","FNP","FP"]
    details["Age groups"]["Sections 2"] = ["M+","FNP+","FP+"]
    details["Age groups"]["Values"]= [["4","0-11 months",get_value("5c", "monthly", start_day, end_day)],
                                      ["5", "1-9 years",get_value("6c", "monthly", start_day, end_day)],
                                      ["6","10-14 years",get_value("7c", "monthly", start_day, end_day)],
                                      ["7","15-19 years",get_value("10a", "monthly", start_day, end_day)],
                                      ["8","20-24 years",get_value("10b", "monthly", start_day, end_day)],
                                      ["9","25 years above",get_value("8c", "monthly", start_day, end_day)]]
    details["Partner Present"] = [["18","Partner",get_value("14", "monthly", start_day, end_day)],
                                  ["19","Partner not",get_value("14a", "monthly", start_day, end_day)],
                                  ["20","Discordant Couples",get_value("14b", "monthly", start_day, end_day)],
                                  ["21","Disc +ve(female)", get_value("14c", "monthly", start_day, end_day)]]
    details["Result Given to Client"] = [["27","New Negative", get_value("27", "monthly", start_day, end_day)],
                                         ["28","Positive", get_value("28", "monthly", start_day, end_day)],
                                         ["29","New exposed infant", get_value("29", "monthly", start_day, end_day)],
                                         ["30","New inconclusive", get_value("30", "monthly", start_day, end_day)],
                                         ["31","Confirmatory positive", get_value("31", "monthly", start_day, end_day)],
                                         ["32","Conf. inconclusive", get_value("32", "monthly", start_day, end_day)]
    ]
    details["HTC Access Type"] = [["10","PITC", get_value("9", "monthly", start_day, end_day)],
                                  ["11","FRS", get_value("10", "monthly", start_day, end_day)],
                                  ["12","Other (VCT, etc)", get_value("11", "monthly", start_day, end_day)]]
    details["Partner HTC Slips Given"] = [["33","Sum of all slips"]]

    details["Test Kit Use Summary"] = {}

    tests = FacilityStock.kits_available

    opening =[ FacilityStock.remaining_stock_by_type(tests[0],start_day, 'opening'), FacilityStock.remaining_stock_by_type(tests[1],start_day, 'opening')]
    closing =[ FacilityStock.remaining_stock_by_type(tests[0],end_day, 'closing'), FacilityStock.remaining_stock_by_type(tests[1],end_day, 'closing')]
    recepts =[ FacilityStock.receipts(tests[0],start_day, end_day), FacilityStock.receipts(tests[1],start_day, end_day)]
    client_tests = [ FacilityStock.client_usage(tests[0],start_day, end_day), FacilityStock.client_usage(tests[1],start_day, end_day)]
    pt_tests = [ FacilityStock.proficiency_usage(tests[0],start_day, end_day,'Test 1'), FacilityStock.proficiency_usage(tests[1],start_day, end_day,'Test 2')]
    losses = [ FacilityStock.losses(tests[0],start_day, end_day), FacilityStock.losses(tests[1],start_day, end_day)]
    closing =[ FacilityStock.remaining_stock_by_type(tests[0],end_day, 'closing'), FacilityStock.remaining_stock_by_type(tests[1],end_day, 'closing')]

    details["Test Kit Use Summary"]["paramers"] = [["Sum Monthly Site Reports, separate for each", "Kit Name", tests],
                                                   ["Total tests in stock at start of 1st day of reporting month","Opening", opening],
                                                   ["Total tests received at this location during this month","Receipts", recepts],
                                                   ["Total tests used for testing clients","Clients", client_tests],
                                                   ["Total tests used for other purposes (QC, PT, Training)","Other",pt_tests],
                                                   ["Total tests expired / disposed, etc","Losses",losses],
                                                   ["Epected remaining Balance","Balance", closing],
                                                   ["Physical tests in stock at end of last day of month","closing", ["",""]],
                                                   ["Excess tests / tests unaccounted for (write + or -)","Difference"
                                                   ]]
    details["Test Kit Use Summary"]["Test 1"] = {}
    details["Test Kit Use Summary"]["Test 2"] = {}

    return details
  end

  def get_value(number, type, start, end_day, sex= "MALE")
      if  number == 3 or number == 4
        type = "UPDATE HIV status"
        et = EncounterType.where(name: type).take.id

       concept_id =get_id( "Patient Pregnant")
       value = get_id("YES")

        preg_patients = Encounter.find_by_sql("SELECT distinct(p.person_id) FROM person p
                          INNER JOIN encounter e ON e.patient_id = p.person_id
                          INNER JOIN obs o ON o.encounter_id = e.encounter_id
                          WHERE p.gender = 'FEMALE' AND
                           e.voided = 0 AND DATE(encounter_datetime) >= '#{start}' AND DATE(encounter_datetime) <= '#{end_day}'
                           AND o.voided = 0 AND o.concept_id = #{concept_id} AND o.value_coded = #{value}
                          AND e.encounter_type = #{et}").map{|p| p.person_id }.join(',') rescue ""
      else
        
      end
      case number
       
        when 2
           type = "HIV Testing"
           et = EncounterType.where(name: type).take.id
           @@males = Encounter.find_by_sql("SELECT distinct(p.person_id) FROM person p
                              INNER JOIN encounter e ON e.patient_id = p.person_id
                              WHERE p.gender = 'MALE' AND
                               e.voided = 0 AND DATE(encounter_datetime) >= '#{start}' AND DATE(encounter_datetime) <= '#{end_day}'
                              AND e.encounter_type = #{et}").map{|p| p.person_id } rescue []

         when 3
           @@non_preg_females = Encounter.find_by_sql("SELECT distinct(p.person_id) FROM person p
                              INNER JOIN encounter e ON e.patient_id = p.person_id
                              WHERE p.gender = 'FEMALE' AND
                               e.voided = 0 AND DATE(encounter_datetime) >= '#{start}' AND DATE(encounter_datetime) <= '#{end_day}'
                              AND e.encounter_type = #{et} AND e.patient_id NOT IN (#{preg_patients})").map{|p| p.person_id } rescue []

         when 4
           type = "HIV Testing"
           et = EncounterType.where(name: type).take.id
           @@preg_females = Encounter.find_by_sql("SELECT distinct(p.person_id) FROM person p
                              INNER JOIN encounter e ON e.patient_id = p.person_id
                              WHERE p.gender = 'FEMALE' AND
                               e.voided = 0 AND DATE(encounter_datetime) >= '#{start}' AND DATE(encounter_datetime) <= '#{end_day}'
                              AND e.encounter_type = #{et} AND e.patient_id IN (#{preg_patients})").map{|p| p.person_id } rescue []
          when "4a"
            return  (@@males + @@non_preg_females + @@preg_females).length

          when "4b"
               return "#{((@@males.length / (@@males.length + @@non_preg_females.length + @@preg_females.length)) * 100)}  %" rescue "0 %"
      when "5"
         @@age_a = get_age(start, end_day, 0, 1)
      when  "5a"
          get_age(start, end_day, 0, 1, "male" )

      when "5b"
           get_age(start, end_day, 0, 1, "female" )

      when "5c"
           get_age_diff(start, end_day, 0, 1 )

       when "6"
         @@age_b = get_age(start, end_day, 1, 15)
      when  "6a"
          get_age(start, end_day, 1, 15, "male" )

      when  "6c"
          get_age_diff(start, end_day, 1, 10 )

      when "6b"
           get_age(start, end_day, 1, 15, "female" )

       when "7"
         @@age_c = get_age(start, end_day, 15, 25)
      when  "7a"
          get_age(start, end_day, 15, 25, "male" )

      when "7b"
           get_age(start, end_day, 15, 25, "female" )

      when  "7c"
          get_age_diff(start, end_day, 10, 15 )
      when "10a"
           get_age_diff(start, end_day, 15, 20 )
      when "10b"
           get_age_diff(start, end_day, 20, 25)

      when "8"
         @@age_d = get_age(start, end_day, 25, 1000)
      when  "8a"
          get_age(start, end_day, 25, 1000, "male" )

      when  "8c"
          get_age_diff(start, end_day, 25, 1000 )

      when "8b"
           get_age(start, end_day, 25, 1000, "female" )
      when "9a"
        return (@@age_c / (@@age_a + @@age_b + @@age_c + @@age_d)) rescue 0
      when "9"
          ids =  (@@males + @@non_preg_females + @@preg_females) rescue []
          get_access_type(ids, "9", start, end_day).length
      when "10"
          ids =  (@@males + @@non_preg_females + @@preg_females) rescue []
          get_access_type(ids, "10", start, end_day).length
      when "11"
          ids =  (@@males + @@non_preg_females + @@preg_females) rescue []
          get_access_type(ids, "11", start, end_day).length
      when "12"
          ids =  (@@males + @@non_preg_females + @@preg_females) rescue []
          pit =get_access_type(ids, "9", start, end_day).length
         total = (pit + get_access_type(ids, "11", start, end_day).length +
               get_access_type(ids, "10", start, end_day).length)
         
         return ( pit.to_f / total.to_f ).to_f.round(2)
      when "14"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("partner or spouse", "YES", start, end_day, ids.join(',') )
      when "14a"
            ids = (@@males + @@non_preg_females + @@preg_females)
           get_results("partner or spouse", "NO", start, end_day, ids.join(',') )
      when "14b"
          ids = (@@males + @@non_preg_females + @@preg_females)
         disc = get_results("spouse/partner", "couple", start, end_day, ids.join(',') )[0]
         return disc
      when "14c"
         ids = (@@males + @@non_preg_females + @@preg_females)
         positive = get_results("spouse/partner", "couple", start, end_day, ids.join(',') )[1]
         
         return positive
      when "15"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Never tested", start, end_day, ids.join(',') )
      when "16"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Negative", start, end_day, ids.join(',') )

      when "17"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Positive", start, end_day, ids.join(',') )
      when "18"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Exposed Infant", start, end_day, ids.join(',') )

      when "19a"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Inconclusive", start, end_day, ids.join(',') )

      when "19b"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Exposed Infant", start, end_day, ids.join(',') )


      when "21"
          ids = (@@males + @@non_preg_females + @@preg_females)
          outcomes( start, end_day, ids.join(','))[0]


      when "22"
          ids = (@@males + @@non_preg_females + @@preg_females)
          outcomes( start, end_day, ids.join(','))[1]


      when "23"
          ids = (@@males + @@non_preg_females + @@preg_females)
          outcomes( start, end_day, ids.join(','))[2]


      when "24"
          ids = (@@males + @@non_preg_females + @@preg_females)
          outcomes( start, end_day, ids.join(','))[3]


      when "25"
          ids = (@@males + @@non_preg_females + @@preg_females)
          outcomes( start, end_day, ids.join(','))[4]


      when "26"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Exposed Infant", start, end_day, ids.join(',') )


      when "27"
          ids = (@@males + @@non_preg_females + @@preg_females)
          results_given("New Negative", start, end_day, ids.join(',') )[0]


      when "28"
          ids = (@@males + @@non_preg_females + @@preg_females)
          results_given("New Positive", start, end_day, ids.join(',') )[1]


      when "29"
          ids = (@@males + @@non_preg_females + @@preg_females)
          results_given("New Exposed Infant", start, end_day, ids.join(',') )[2]


      when "30"
          ids = (@@males + @@non_preg_females + @@preg_females)
          results_given("Confirmatory Positive", start, end_day, ids.join(',') )[3]


      when "31"
          ids = (@@males + @@non_preg_females + @@preg_females)
          results_given("New Inconclusive", start, end_day, ids.join(',') )[4]


      when "32"
          ids = (@@males + @@non_preg_females + @@preg_females)
          results_given("Inconclusive", start, end_day, ids.join(',') )[5]


      when "33a"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Exposed Infant", start, end_day, ids.join(',') )


      when "34"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Exposed Infant", start, end_day, ids.join(',') )

       when "35"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Exposed Infant", start, end_day, ids.join(',') )

       when "36"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Exposed Infant", start, end_day, ids.join(',') )

       when "37"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Exposed Infant", start, end_day, ids.join(',') )

       when "38"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("last HIV test", "Last Exposed Infant", start, end_day, ids.join(',') )

       when "40"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("Client Risk Category", "Low Risk", start, end_day, ids.join(',') )

       when "41"
          ids = (@@males + @@non_preg_females + @@preg_females)
          get_results("Client Risk Category", "AVD+ or High Risk", start, end_day, ids.join(',') )
      end
  end

  def get_results(concept, answer, start, end_day, ids)
      value_coded = get_id(answer) rescue ""
      concept_id = get_id(concept) rescue ""
      type = "HIV Testing"
       et = EncounterType.where(name: type).take.id
      if concept == "partner or spouse" and answer =="NO"
       
      encounter = Encounter.find_by_sql("SELECT DISTINCT(e.patient_id) FROM person p
                               INNER JOIN encounter e ON e.patient_id = p.person_id
                               WHERE e.voided = 0 
                              AND e.encounter_type = #{et}
                              AND DATE(encounter_datetime) >= '#{start}'
                              AND DATE(encounter_datetime) <= '#{end_day}'
                              AND e.patient_id NOT IN
                              (SELECT DISTINCT(o.person_id) FROM obs o
                              WHERE  o.voided = 0 AND DATE(obs_datetime) >= '#{start}' AND DATE(obs_datetime) <= '#{end_day}'
                              AND o.concept_id = #{concept_id} AND o.value_coded = #{value_coded} AND o.person_id IN (#{ids}))").map{|p| p.person_id }.uniq.length rescue 0

    elsif concept == "spouse/partner" and answer == "couple"
              concept_id = get_id("partner or spouse")
                value_coded= get_id("YES")

              encounter = Encounter.find_by_sql("SELECT DISTINCT(o.person_id) FROM obs o
                              WHERE  o.voided = 0 AND DATE(obs_datetime) >= '#{start}' AND DATE(obs_datetime) <= '#{end_day}'
                              AND o.concept_id = #{concept_id}
                               AND o.value_coded = #{value_coded} AND o.person_id IN (#{ids})").map{|p| p.person_id }.join(',') rescue []

              relationship_type = RelationshipType.where("a_is_to_b = 'spouse/partner'").first.relationship_type_id
              relation = Relationship.where("(person_a IN (#{encounter}) AND person_b = (#{encounter}))
                                                                  OR (person_a = (#{encounter}) AND person_b = (#{encounter}))
                                                                  AND relationship = ?", relationship_type).order(relationship_id: :desc).collect { |p|
                                                                  [p.person_a, p.person_b]} rescue []

             concept_id = get_id("Result of hiv test")
              discordant = 0
              positive = 0
              relation.each { |r|
                    r_1 = spouse_result(start, end_day, r[0], concept_id)
                    r_2 = spouse_result(start, end_day, r[1], concept_id)
                    if r_1 != r_2
                      discordant += 1
                       if Person.find(r[0]).gender.upase == "FEMALE" and r_1.upcase == "NEGATIVE"
                          positive += 1
                       end
                       if Person.find(r[1]).gender.upase == "FEMALE" and r_2.upcase == "NEGATIVE"
                           positive += 1
                       end
                    end
            
              }
           
             return [discordant , positive]
    else
         encounter = Encounter.find_by_sql("SELECT DISTINCT(o.person_id) FROM obs o
                              WHERE  o.voided = 0 AND DATE(obs_datetime) >= '#{start}' AND DATE(obs_datetime) <= '#{end_day}'
                              AND o.concept_id = #{concept_id} AND o.value_coded = #{value_coded} AND o.person_id IN (#{ids})").map{|p| p.person_id }.uniq.length rescue 0
       end
  end

  def get_age_diff(start, end_day, min, max)
       m = 0
       fnp = 0
       fp = 0
       m_pos = 0
       fnp_pos = 0
       fp_pos = 0
       concept_id = get_id("Result of hiv test")
       type = "HIV Testing"
       et = EncounterType.where(name: type).take.id
       Encounter.find_by_sql("SELECT DISTINCT(p.person_id) FROM person p
                              INNER JOIN encounter e ON e.patient_id = p.person_id
                              WHERE  COALESCE(DATEDIFF(NOW(), p.birthdate)/365, 0) >= #{min}
                              AND COALESCE(DATEDIFF(NOW(), p.birthdate)/365, 0) < #{max} 
                               AND e.voided = 0 AND DATE(encounter_datetime) >= '#{start}' AND DATE(encounter_datetime) <= '#{end_day}'
                              AND e.encounter_type = #{et}").each{|p|
                                    if @@preg_females.include?(p.person_id)
                                      fp += 1
                                      fp_pos += 1 if spouse_result(start, end_day, p.person_id, concept_id).upcase == "POSITIVE"
                                    end
                                    if @@non_preg_females.include?(p.person_id)
                                      fnp += 1
                                      fnp_pos += 1 if spouse_result(start, end_day, p.person_id, concept_id).upcase == "POSITIVE"
                                    end
                                    if @@males.include?(p.person_id)
                                       m += 1
                                       m_pos += 1 if spouse_result(start, end_day, p.person_id, concept_id).upcase == "POSITIVE"
                                    end
                                    p.person_id
                              }# rescue []
       return [m, fnp, fp, m_pos, fnp_pos, fp_pos]
      
  end
  def outcomes( start, end_day, ids)
       type = "HIV Testing"
       et = EncounterType.where(name: type).take.id

      single_neg = 0
      single_pos = 0
      t1_t2_neg = 0
      t1_t2_pos = 0
      t1_t2_disc = 0

      test_1 = get_id("HTC Test 1 result")
      test_2 = get_id("HTC Test 2 result")
    (ids.split(',') || []).each { |p|
        latest = Encounter.where("encounter_type = #{et} AND patient_id = #{p}
          AND DATE(encounter_datetime) >= ? AND DATE(encounter_datetime) <= ?",
          start, end_day).order(encounter_datetime: :desc).pluck(:encounter_id).max

       first_result = Encounter.find(latest).observations.where(concept_id: test_1).first.answer_string.squish rescue ""
       second_result = Encounter.find(latest).observations.where(concept_id: test_2).first.answer_string.squish rescue ""

       if first_result.blank? or second_result.blank?
          if first_result.upcase == "NEGATIVE" or second_result.upcase == "NEGATIVE"
              single_neg += 1
          elsif first_result.upcase == "POSITIVE" or second_result.upcase == "POSITIVE"
              single_pos += 1
          end
       elsif first_result.upcase == "POSITIVE" and second_result.upcase == "POSITIVE"
          t1_t2_pos += 1
        elsif first_result.upcase == "NEGATIVE" and second_result.upcase == "NEGATIVE"
           t1_t2_neg += 1
       else
           t1_t2_disc += 1
       end     
    }

    return [single_neg, single_pos, t1_t2_neg, t1_t2_pos, t1_t2_disc]
  end

  def results_given(cat, start, end_day, ids)
    concept_id = get_id("last hiv test")
    value_coded =  get_id("Never Tested")
    new_patients = Observation.find_by_sql("SELECT DISTINCT(person_id) FROM obs o
                              WHERE  o.voided = 0 AND DATE(obs_datetime) >= '#{start}' AND DATE(obs_datetime) <= '#{end_day}'
                              AND o.concept_id = #{concept_id} AND value_coded = #{value_coded} AND o.person_id IN (#{ids}) ORDER BY obs_datetime DESC LIMIT 1").map{|p| p.person_id } rescue []
   
    concept_id = get_id("Result of hiv test")
    new_pos = 0
    new_neg = 0
    new_exposed = 0
    new_inc = 0
    positive = 0
    inc = 0
    if cat == "New Positive" or cat == "New Negative" or cat == "New Exposed Infant" or cat == "New Inconclusive"
      (new_patients || []).each{|p|
           result = spouse_result(start, end_day, p, concept_id)

           if result.upcase == "NEGATIVE"
             new_neg += 1
           elsif result.upcase == "POSITIVE"
             new_pos += 1
           elsif result.upcase == "EXPOSED INFANT"
             new_exposed += 1
           elsif result.upcase == "INCONCLUSIVE"
             new_inc += 1
           end
      }
    else
      (ids.split(',') || []).each { |p|
          result = spouse_result(start, end_day, p, concept_id)
          if result.upcase == "INCONCLUSIVE"
             inc += 1
          elsif result.upcase == "POSITIVE"
             positive += 1
          end

      }
    end
    return [new_neg, new_pos,  new_exposed, positive, new_inc, inc]
  end

  def spouse_result(start, end_day, r, concept_id)
      e = Observation.find_by_sql("SELECT * FROM obs o
                              WHERE  o.voided = 0 AND DATE(obs_datetime) >= '#{start}' AND DATE(obs_datetime) <= '#{end_day}'
                              AND o.concept_id = #{concept_id} AND o.person_id = #{r} ORDER BY obs_datetime DESC LIMIT 1").first.answer_string.squish

  end

  def get_access_type(ids, segment, start, end_day)
      concept = {}
      concept["9"] = "Routine HTC with health service"
      concept["10"] = "Comes with HTC family Ref slip"
      concept["11"]  = "Other"
      patient = []
      value_coded = get_id(concept[segment])
      concept_id = get_id("HTC Access Type")
      (ids  || []).each{|id|
          o = Observation.where(" concept_id = #{concept_id} AND person_id = #{id}
            AND value_coded = #{value_coded}
            AND DATE(obs_datetime) >= '#{start}'
            AND DATE(obs_datetime) <= '#{end_day}'").order(obs_datetime: :desc).first rescue []
          unless o.blank?
             patient << o.person_id
          end
      }
      return patient
  end

  def get_age(start, end_day, min, max, sex = nil)
         unless sex.blank?
            condition = " AND p.gender = '#{sex}' "
         end
         type = "HIV Testing"
         et = EncounterType.where(name: type).take.id
         encounter = Encounter.find_by_sql("SELECT DISTINCT(p.person_id) FROM person p
                              INNER JOIN encounter e ON e.patient_id = p.person_id
                              WHERE  COALESCE(DATEDIFF(NOW(), p.birthdate)/365, 0) >= #{min}
                              AND COALESCE(DATEDIFF(NOW(), p.birthdate)/365, 0) < #{max} #{condition}
                               AND e.voided = 0 AND DATE(encounter_datetime) >= '#{start}' AND DATE(encounter_datetime) <= '#{end_day}'
                              AND e.encounter_type = #{et}").map{|p| p.person_id }.length rescue 0

  end

  def new_test
      @tests = ["Official Result"]
  end

  def build_date(mon, yr)
        if (mon.length == 3)
         month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
         month = month.index(mon) + 1;
        else
          month = mon.to_i + 1
        end

        start_day = "#{yr}-#{month}-01".to_date
				return start_day,  start_day.end_of_month
  end

  def get_id(concept)
    concept_id = ConceptName.where(name: concept).first.concept_id
  end

  def get_name(concept)
    concept_name = ConceptName.find(concept).name
  end
end
