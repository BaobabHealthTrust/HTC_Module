class ConceptName < ActiveRecord::Base
	self.table_name = "concept_name"
	include Openmrs
	
  has_many :concept_name_tag_maps # no default scope
  has_many :tags, :through => :concept_name_tag_maps, :class_name => 'ConceptNameTag'
  belongs_to :concept, -> { where retired:  0}
  scope :tagged, lambda{|tags| tags.blank? ? {} : {:include => :tags, :conditions => ['concept_name_tag.tag IN (?)', Array(tags)]}}
  scope :typed, lambda{|tags| tags.blank? ? {} : {:conditions => ['concept_name_type IN (?)', Array(tags)]}}
  self.default_scope :joins => :concept, :conditions => "concept_name.voided = 0 AND concept.retired = 0 AND concept_name.name != ''"

	
end
