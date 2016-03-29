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

  def districts_for

    region_id = Region.find_by_name("#{params[:filter_value]}").id rescue nil
    region_conditions = ["name LIKE (?) AND region_id = ? ", "%#{params[:search_string]}%", region_id]

    districts = District.find(:all,:conditions => region_conditions, :order => 'name') rescue []
    districts = districts.map do |d|
      d.name
    end

    if region_id.blank?
      countries= []
      File.open(RAILS_ROOT + "/public/data/countries.txt", "r").each{ |ctry|
        countries << ctry.strip
      }
      if countries.length > 0
        countries = (["Mozambique", "Zambia", "Tanzania", "Zimbabwe", "Nigeria", "Namibia"] + countries).uniq
      end
      districts = countries
    end

    render :text => (districts + ["Other"]).join('|')  and return
  end

  def static_nationalities
    search_string = (params[:search_string] || "").upcase

    nationalities = []
    File.open("public/data/nationalities.txt", "r").each{ |nat|
      nationalities << nat if nat.upcase.strip.match(search_string)
    }

    render :text => "<li></li><li " + nationalities.map{|nationality| "value=\"#{nationality}\">#{nationality}" }.join("</li><li ") + "</li>"

  end

  def static_countries
    search_string = (params[:search_string] || "").upcase

    nationalities = []

    File.open("public/data/countries.txt", "r").each{ ||
      nationalities << c if c.upcase.strip.match(search_string)
    }

    render :text => "<li></li><li " + nationalities.map{|ctry| "value=\"#{ctry}\">#{ctry}" }.join("</li><li ") + "</li>"

  end

  def traditional_authority
    district_id = District.find_by_name("#{params[:filter_value]}").id rescue nil
    traditional_authority_conditions = ["name LIKE (?) AND district_id = ?", "%#{params[:search_string]}%", district_id]

    traditional_authorities = TraditionalAuthority.find(:all,:conditions => traditional_authority_conditions, :order => 'name') rescue []
    traditional_authorities = traditional_authorities.map do |t_a|
      "<li value='#{t_a.name}'>#{t_a.name}</li>"
    end
    render :text => traditional_authorities.join('') + "<li value='Other'>Other</li>" and return
  end

  def traditional_authority_for
    district_id = District.find_by_name("#{params[:filter_value]}").id
    traditional_authority_conditions = ["name LIKE (?) AND district_id = ?", "%#{params[:search_string]}%", district_id]

    traditional_authorities = TraditionalAuthority.find(:all,:conditions => traditional_authority_conditions, :order => 'name')
    traditional_authorities = traditional_authorities.map do |t_a|
      t_a.name
    end
    render :text => (traditional_authorities + ["Other"]).join('|') and return
  end

  def village
    ta = params[:value] || params[:filter_value]
    ta_id = TraditionalAuthority.where(:name => ta).first.id
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

  def landmark
    landmarks = ["", "Market", "School", "Police", "Church", "Borehole", "Graveyard"]
    landmarks = landmarks.map do |v|
      "<li value='#{v}'>#{v}</li>"
    end
    render :text => landmarks.join('') + "<li value='Other'>Other</li>" and return
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
