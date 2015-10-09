class EncounterRole < ActiveRecord::Base
  self.table_name = 'encounter_role'
  self.primary_key = 'encounter_role_id'
  include Openmrs
end
