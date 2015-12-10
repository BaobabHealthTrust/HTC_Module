class PersonAddress < ActiveRecord::Base
	self.table_name = "person_address"
  self.primary_key = "person_address_id"
  include Openmrs
	before_save :before_create
  
  belongs_to :person, -> {where voided: 0}, foreign_key: :person_id


  
end
