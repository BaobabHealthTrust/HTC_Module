require "client_service"

class PeopleController < ApplicationController
  include ClientService

  def new
    if request.post?

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
    ta_id = TraditionalAuthority.where(:name => params[:value]).first.id
    villages = Village.where(:traditional_authority_id => ta_id)
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
