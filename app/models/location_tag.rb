class LocationTag < ActiveRecord::Base
	self.table_name = 'location_tag'

	include Openmrs
	before_save :before_create
end
