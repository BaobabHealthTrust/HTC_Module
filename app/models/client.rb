class Client < ActiveRecord::Base
	self.table_name = 'patient'
	include Openmrs

	before_save :before_create
end
