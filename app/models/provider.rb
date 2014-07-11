class Provider < ActiveRecord::Base
  self.table_name = 'provider'
  self.primary_key = 'provider_id'
  include Openmrs
	
	has_one :person, :foreign_key => :person_id, :conditions => {:voided => 0}
end
