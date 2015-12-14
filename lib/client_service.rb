module ClientService


  def self.create_person(params)
    return nil if params.blank?
    person_params = params['person']
    address_params = params[:person]["addresses"]
    names_params = params[:person]["names"]

    if person_params["gender"].to_s == "Female"
      person_params["gender"] = 'Female'
    elsif person_params["gender"].to_s == "Male"
      person_params["gender"] = 'Male'
    end

    if person_params["birth_year"] == "Unknown"
      birthdate_values = self.set_birthdate_by_age(person_params["age_estimate"], Date.today)
      birthdate = birthdate_values[0]
      birthdate_estimated = birthdate_values[1]
    else
      birthdate_values = self.set_birthdate(person_params["birth_year"], person_params["birth_month"], person_params["birth_day"])
      birthdate = birthdate_values[0]
      birthdate_estimated = birthdate_values[1]
    end

    unless person_params['birthdate_estimated'].blank?
       birthdate_estimated = person_params['birthdate_estimated'].to_i
    end

    person = Person.create(gender: person_params['gender'], birthdate: birthdate, 
      birthdate_estimated: birthdate_estimated)

    client = Client.create(patient_id: person.id)
    client.set_htc_number

    PersonName.create(given_name: names_params['given_name'], family_name: names_params['family_name'], person_id: person.id)
    PersonAddress.create(address1: address_params['state_province'], address2: address_params['city_village'], person_id: person.id, county_district: address_params['county_district']) unless address_params.empty? rescue nil

    PersonAttribute.create(
      person_attribute_type_id: PersonAttributeType.find_by_name("Occupation").person_attribute_type_id,
      value: person_params["occupation"], person_id: person.id) unless person_params["occupation"].blank? rescue nil

    PersonAttribute.create(
      person_attribute_type_id: PersonAttributeType.find_by_name("Cell Phone Number").person_attribute_type_id,
      value: person_params["cell_phone_number"], person_id: person.id) unless person_params["cell_phone_number"].blank? rescue nil

    PersonAttribute.create(
      person_attribute_type_id: PersonAttributeType.find_by_name("Office Phone Number").person_attribute_type_id,
      value: person_params["office_phone_number"], person_id: person.id) unless person_params["office_phone_number"].blank? rescue nil

    PersonAttribute.create(
      person_attribute_type_id: PersonAttributeType.find_by_name("Home Phone Number").person_attribute_type_id,
      value: person_params["home_phone_number"], person_id: person.id) unless person_params["home_phone_number"].blank? rescue nil

    return person

  end

  def self.set_birthdate(year = nil, month = nil, day = nil)
    raise "No year passed for estimated birthdate" if year.nil?

    # Handle months by name or number (split this out to a date method)
    month_i = (month || 0).to_i
    month_i = Date::MONTHNAMES.index(month) if month_i == 0 || month_i.blank?
    month_i = Date::ABBR_MONTHNAMES.index(month) if month_i == 0 || month_i.blank?

    if month_i == 0 || month == "Unknown"
      birthdate = Date.new(year.to_i,7,1)
      birthdate_estimated = 1
    elsif day.blank? || day == "Unknown" || day == 0
      birthdate = Date.new(year.to_i,month_i,15)
      birthdate_estimated = 1
    else
      birthdate = Date.new(year.to_i,month_i,day.to_i)
      birthdate_estimated = 0
    end
    return [birthdate, birthdate_estimated]
  end

  def self.set_birthdate_by_age(age, today = Date.today)
    birthdate = Date.new(today.year - age.to_i, 7, 1)
    return [birthdate, 1]
  end

end
