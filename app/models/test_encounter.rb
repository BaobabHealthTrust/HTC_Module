class TestEncounter < ActiveRecord::Base
	self.table_name = 'test_encounter'
  include Openmrs
end
