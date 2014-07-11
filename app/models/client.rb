class Client < ActiveRecord::Base
	self.table_name = 'patient'
	include Openmrs

	before_save :before_create
	has_one :person, :foreign_key => :person_id, :conditions => {:voided => 0}
end
