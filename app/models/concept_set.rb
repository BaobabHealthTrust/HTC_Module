class ConceptSet < ActiveRecord::Base
  self.table_name =  "concept_set"
  include Openmrs
  belongs_to :set, -> { where retired: 0 }, :class_name => "Concept"
  belongs_to :concept, -> { where retired: 0}
end
