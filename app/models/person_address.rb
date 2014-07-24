class PersonAddress < ActiveRecord::Base
	self.table_name = "person_address"
  self.primary_key = "person_address_id"
  include Openmrs
	before_save :before_create
end
