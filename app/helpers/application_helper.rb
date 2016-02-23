module ApplicationHelper

  def settings 
    OpenStruct.new YAML.load_file("#{Rails.root}/config/settings.yml")
  end

	def get_global_property_value(property)
		settings[property] rescue nil
	end
  
  def month_name_options(selected_months = [])
    i=0
    options_array = [[]] +Date::ABBR_MONTHNAMES[1..-1].collect{|month|[month,i+=1]} + [["Unknown","Unknown"]]
    options_for_select(options_array, selected_months)
  end

  def age_limit
    Time.now.year - 1890
  end

  def ask_ground_phone
    get_global_property_value("demographics.ground_phone").to_s == "true" rescue false
  end

end
