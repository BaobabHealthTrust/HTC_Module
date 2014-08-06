class CounselingAnswer < ActiveRecord::Base
  self.table_name = 'counseling_answer'
  self.primary_key = 'answer_id'
  include Openmrs
	
	before_save :before_create

  belongs_to :encounter, -> {where voided: 0}, foreign_key: "encounter_id"
  belongs_to :counseling_question, -> {where retired: 0}, foreign_key: "question_id"

	def to_s(tags=[])
    formatted_name = self.counseling_question.name rescue nil
    formatted_answer ||= ConceptName.find_by_concept_id(self.value_coded).name if ! self.value_coded.blank? 
		formatted_answer ||= self.value_datetime.strftime("%d/%m/%Y") if ! self.value_datetime.blank?
		formatted_answer ||= self.value_numeric if ! self.value_numeric.blank?
		formatted_answer ||= self.value_text if ! self.value_text.blank?
    "<b>#{formatted_name}:</b>  #{formatted_answer}"
  end
end
