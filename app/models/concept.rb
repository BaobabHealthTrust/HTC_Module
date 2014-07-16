class Concept < ActiveRecord::Base
	self.table_name = "concept"
	include Openmrs

  belongs_to :concept_class, -> { where retired: 0}
  belongs_to :concept_datatype, -> { where retired: 0}
  has_one :concept_numeric, foreign_key: "concept_id", dependent: :destroy
  has_many :answer_concept_names, -> { where voided: 0}, class_name: "ConceptName"
  has_many :concept_names, -> { where voided: 0}
  has_many :concept_sets  # no default scope
  has_many :concept_answers do # no default scope
    def limit(search_string)
      return self if search_string.blank?
      map{|concept_answer|
        concept_answer if concept_answer.name.match(search_string)
      }.compact
    end
  end
  has_many :concept_members, :class_name => 'ConceptSet', :foreign_key => :concept_set
end
