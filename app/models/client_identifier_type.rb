class ClientIdentifierType < ActiveRecord::Base
	self.table_name = "patient_identifier_type"
  self.primary_key = "patient_identifier_type_id"
	include Openmrs
	
	before_save :before_create
end
