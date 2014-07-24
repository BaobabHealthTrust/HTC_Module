class EncounterProvider < ActiveRecord::Base
  self.table_name = 'encounter_provider'
  self.primary_key = 'encounter_provider_id'
  include Openmrs
end
