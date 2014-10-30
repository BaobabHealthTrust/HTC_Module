class Relationship < ActiveRecord::Base
  self.table_name = "relationship"
  self.primary_key = "relationship_id"
  include Openmrs
  belongs_to :person, -> {where voided: 0}, class_name: 'Person', foreign_key: :person_a
  belongs_to :relation, -> {where voided: 0}, class_name: 'Person', foreign_key: :person_b
  belongs_to :type, class_name: "RelationshipType", foreign_key: :relationship # no default scope, should have retired
  
	scope :spouse, -> {where 'relationship_type.b_is_to_a = "Spouse/Partner" OR relationship_type.a_is_to_b = "Spouse/Partner"'}
  
  def to_s
    self.type.b_is_to_a + ": " + (relation.names.first.given_name + ' ' + relation.names.first.family_name rescue '')
  end
  
	def partner
		
	end
end