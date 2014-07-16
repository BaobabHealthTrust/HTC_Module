class Encounter < ActiveRecord::Base
  self.table_name = 'encounter'
  self.primary_key = 'encounter_id'
  include Openmrs
	
	before_save :before_create
	belongs_to :client, -> { where retired: 0}, foreign_key: "patient_id"
	
end
