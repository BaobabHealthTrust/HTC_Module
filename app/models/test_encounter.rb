class TestEncounter < ActiveRecord::Base
	self.table_name = 'test_encounter'
  include Openmrs

  def self.temperatures(start_date = Date.today, end_date = Date.today)

    data = TestObservation.where(concept_id: ConceptName.where(name: "Temperature").first.concept_id
    ).joins("INNER JOIN test_encounter
              ON test_observation.encounter_id = test_encounter.id AND test_encounter.test_encounter_type =
              (SELECT id from test_encounter_type WHERE name = 'Temperature Quality Control' LIMIT 1)"
    ).select(:value_numeric, :obs_datetime)
    return data
  end
end
