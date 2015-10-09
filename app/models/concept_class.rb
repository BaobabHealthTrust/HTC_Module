class ConceptClass < ActiveRecord::Base
  self.table_name = "concept_class"
  self.primary_key = "concept_class_id"
  include Openmrs

  has_many :concepts, -> {where retired: 0}, class_name: 'Concept', foreign_key: 'class_id'

end
