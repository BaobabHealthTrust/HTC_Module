class ConceptNameTagMap < ActiveRecord::Base
	self.table_name = 'concept_name_tag_map'
	include Openmrs

  belongs_to :tag, -> {where voided: 0}, foreign_key: "concept_name_tag_id", class_name: 'ConceptNameTag'
  belongs_to :concept_name_tag, -> {where voided: 0}
  belongs_to :concept_name, -> {where retired: 0}
end
