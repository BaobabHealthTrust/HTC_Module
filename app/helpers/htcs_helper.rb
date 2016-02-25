module HtcsHelper

	def settings 
    	OpenStruct.new YAML.load_file("#{Rails.root}/config/settings.yml")
  	end
  	
	def facility_name
		 settings.facility_name
	end
	
	def refresh_dashboard
		settings.refresh_dashboard
	end
end
