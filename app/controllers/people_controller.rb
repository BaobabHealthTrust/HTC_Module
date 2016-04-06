require "client_service"
require "rest-client"

class PeopleController < ApplicationController
  skip_before_action :verify_authenticity_token
  include ClientService

  def new
    if request.post?
      new_params = params["person"]

      demographics = {
      "person" => {
        "birth_day" => "#{new_params[:birth_day]}",
        "birth_month" => "#{new_params[:birth_month]}",
        "birth_year" => "#{new_params[:birth_year]}",
        "gender" => "#{new_params[:gender]}",
        "age_estimate" => "#{new_params[:age_estimate].to_i}",
        "names" => {
          "given_name" => "#{new_params[:names][:given_name]}",
          "family_name" => "#{new_params[:names][:family_name]}",
          "family_name2" => "#{new_params[:names][:family_name2]}"
        },

        "addresses" => {
          "address1" => "#{new_params[:addresses][:address1]}",
          "address2" => "#{new_params[:addresses][:address2]}",
          "city_village" => "#{new_params[:addresses][:city_village]}",
          "county_district" => "#{new_params[:addresses][:county_district]}"
        },

        "occupation" => "#{new_params[:occupation]}",
        "cell_phone_number" => "#{new_params[:cell_phone_number]}",
        "office_phone_number" => "#{new_params[:office_phone_number]}",
        "home_phone_number" => "#{new_params[:home_phone_number]}",
        "patient" => ""
      }
    }

      create_from_remote = settings.create_from_remote
      bart_ip_address_and_port = settings.bart2_address
      if create_from_remote.to_s == 'true'
        if bart_ip_address_and_port.match(/^http/)
          uri = "#{bart_ip_address_and_port}/people/create_person_from_dmht"
        else
          uri = "http://#{bart_ip_address_and_port}/people/create_person_from_dmht"
        end

        remote_patient_national_id =  RestClient.post(uri,demographics)
        params["patient"] = {"national_id" => remote_patient_national_id}
      end
      
      person = ClientService.create_person(params, current_user.id)

      current = session[:datetime].to_datetime.strftime("%Y-%m-%d %H:%M:%S") rescue DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
      write_encounter("IN WAITING", person, current)
      redirect_to controller: 'clients', action: 'search_new', residence: person.addresses.first.address1,
                  gender: person.gender, date_of_birth: person.birthdate_for_printing and return
    end
    
    @occupations = ["","Business", "Craftsman","Domestic worker","Driver","Farmer","Health worker",
                    "Housewife","Mechanic","Messenger","Office worker","Police","Preschool child", "Salesperson",
                  "Security guard","Soldier","Student","Teacher","Other","Unknown"]

    render :layout => 'basic'
  end

  def create_remote_person
    person_obj = JSON.parse(params["person"])
    person_obj["person"]["patient"] = {"national_id" => person_obj["person"]["patient"]["identifiers"]["National id"]}
    person = ClientService.create_person(person_obj, current_user.id)
    redirect_to("/client_demographics?client_id=#{person.person_id}") and return
  end
  
  def write_encounter(encounter_type, person, current = DateTime.now)
    current = session[:datetime] if !session[:datetime].blank?
    type = EncounterType.find_by_name(encounter_type).id

    current_location = @current_location if current_location.nil?
    encounter = Encounter.create(encounter_type: type, patient_id: person.id,
                                 encounter_datetime: current.to_datetime.strftime("%Y-%m-%d %H:%M:%S"),
                                 creator: current_user.id)
  end


  def region
    regions = (Region.all || []).map do |r|
      "<li value=\"#{r.name}\">#{r.name}</li>"
    end
    render :text => regions.join('')  and return
  end

  def village
    ta_id = TraditionalAuthority.where(:name => params[:value]).first.id;
    villages = Village.where("traditional_authority_id = ? AND name LIKE (?)",ta_id, "#{params[:search_string]}%")
    
    regions = (villages || []).map do |r|
      "<li value=\"#{r.name}\">#{r.name}</li>"
    end
    render :text => regions.join('')  and return
  end

  def districts
    if params[:search_string].blank?
      districts = District.where(:region_id => Region.where(:name => params[:value]).first.id)
    else
      region_id = Region.where(:name => params[:value]).first.id
      districts = District.where("region_id = ? AND name LIKE (?)",region_id, "#{params[:search_string]}%")
    end
    regions = (districts || []).map do |r|
      "<li value=\"#{r.name}\">#{r.name}</li>"
    end
    render :text => regions.join('')  and return
  end

   def ta
    #return if params[:search].blank?
    # location = TraditionalAuthority.where("name LIKE '%#{params[:search]}%'")
    location = District.find_by_sql("SELECT d.name as district_name, ta.name as ta_name
    FROM district d
    Inner join traditional_authority ta
    on d.district_id = ta.district_id 
    where d.name LIKE  '%#{params[:value]}%' AND ta.name LIKE '%#{params[:search_string]}%'")

    location = location.map do |l|
        "<li value=\"#{l.ta_name}\">#{l.ta_name}</li>"
    end
    render :text => location.join('')  and return
  end

end
