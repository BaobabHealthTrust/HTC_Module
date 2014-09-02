class Client < ActiveRecord::Base
	self.table_name = 'patient'
	include Openmrs

	before_save :before_create
	has_one :person, -> {where voided: 0}, foreign_key: "person_id"
	has_many :encounters, -> { where voided: 0}, foreign_key: "patient_id", dependent: :destroy

  def tested(date = Date.today)
     type = EncounterType.where("name = ?", "HIV TESTING").first.id
    encounter = Encounter.where("encounter_type = ? AND DATE(encounter_datetime) = ?",
                          type, date).order(encounter_datetime: :desc).first rescue []
  end

 def referred(date = Date.today)
     type = EncounterType.where("name = ?", "REFERRAL CONSENT CONFIRMATION").first.id
    encounter = Encounter.where("encounter_type = ? AND DATE(encounter_datetime) = ?",
                          type, date).order(encounter_datetime: :desc).first rescue []
  end

  def counselled(date = Date.today)
     type = EncounterType.where("name = ?", "COUNSELING").first.id
    encounter = Encounter.where("encounter_type = ? AND DATE(encounter_datetime) = ?",
                          type, date).order(encounter_datetime: :desc).first rescue []
  end

  def appointment(date = Date.today)
     type = EncounterType.where("name = ?", "APPOINTMENT").first.id
    encounter = Encounter.where("encounter_type = ? AND DATE(encounter_datetime) = ?",
                          type, date).order(encounter_datetime: :desc).first rescue []
  end

	def current_state(date=Date.today)
		ids = []
		id_name_hash = {}
		
		state_encounters = ['IN WAITING', 'IN SESSION',
												'HIV Testing', 'Referral Consent Confirmation',
												'Counseling']
		EncounterType.where("name IN (?)",state_encounters)
								 .each do |e|
										ids << e.id
										id_name_hash[e.id]=e.name
									end
		
		state = encounters.where("encounter_type IN (?) AND DATE(encounter_datetime)= ?", ids, date)
									 .order(encounter_datetime: :desc).first
	end

  def first_state(date=Date.today)
		ids = []
		id_name_hash = {}

		state_encounters = ['IN WAITING', 'IN SESSION',
												'HIV Testing', 'Referral Consent Confirmation',
												'Counseling']
		EncounterType.where("name IN (?)",state_encounters)
								 .each do |e|
										ids << e.id
										id_name_hash[e.id]=e.name
									end

		state = encounters.where("encounter_type IN (?) AND DATE(encounter_datetime)= ?", ids, date)
									 .order(encounter_datetime: :desc).last
	end

 def final_state(date=Date.today)
		ids = []
		id_name_hash = {}

		state_encounters = ['IN WAITING', 'IN SESSION',
												'HIV Testing', 'Referral Consent Confirmation',
												'Counseling']
		EncounterType.where("name IN (?)",state_encounters)
								 .each do |e|
										ids << e.id
										id_name_hash[e.id]=e.name
									end

		id = encounters.select("distinct encounter_type ").where("encounter_type IN (?) AND DATE(encounter_datetime)= ?", ids, date)
			state = []
		 if id.length == 6
			state = encounters.where("encounter_type IN (?) AND DATE(encounter_datetime)= ?", ids, date)
									 .order(encounter_datetime: :desc).first
		 end
			return state
	end
	
	def name
		  "#{person.names.first.given_name  rescue ' '} #{person.names.first.family_name rescue ' '}"
	end
	
	def accession_number
		  identifier_type = ClientIdentifierType.find_by_name("HTC Identifier").id
			ClientIdentifier.find(:last, 
													  :conditions => ["identifier_type = ? AND patient_id = ?", 
														identifier_type, self.id]).identifier rescue ""
	end
	
	def has_booking
		concept_id = ConceptName.find_by_name("APPOINTMENT DATE").id
		
		Observation.find_by_sql("
			SELECT  last_appointment.*, last_encounter.encounter_datetime
				FROM (
							SELECT person_id, concept_id, MAX(value_datetime) AS value_datetime
								FROM obs
								WHERE person_id = #{self.id} AND concept_id=#{concept_id} AND voided=0
								GROUP BY person_id
							) AS last_appointment
					LEFT JOIN (
							SELECT patient_id, MAX(encounter_datetime) AS encounter_datetime
								FROM encounter
								WHERE voided=0
								GROUP BY patient_id
							) AS last_encounter
					ON last_appointment.person_id=last_encounter.patient_id
					WHERE last_appointment.value_datetime > last_encounter.encounter_datetime
		").first rescue nil
	end
end
