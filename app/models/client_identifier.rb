class ClientIdentifier < ActiveRecord::Base
	self.table_name = 'patient_identifier'
	self.primary_key = 'patient_identifier_id'
	include Openmrs

	before_save :before_create
end
