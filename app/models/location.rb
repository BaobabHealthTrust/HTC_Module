class Location < ActiveRecord::Base
	self.table_name = 'location'

	include Openmrs
	before_save :before_create
end
