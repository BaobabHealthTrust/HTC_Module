class Client < ActiveRecord::Base
	self.table_name = 'patient'
	include Openmrs

	before_save :before_create
	has_one :person, -> {where voided: 0}, foreign_key: "person_id"
	has_many :encounters, -> { where voided: 0}, foreign_key: "patient_id", dependent: :destroy
end
