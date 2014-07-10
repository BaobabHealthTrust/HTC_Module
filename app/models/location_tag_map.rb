class LocationTagMap < ActiveRecord::Base
	self.table_name = 'location_tag_map'

	include Openmrs
	before_save :before_create
end
