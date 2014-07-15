class CounselingQuestion < ActiveRecord::Base
  self.table_name = 'counseling_question'
  self.primary_key = 'question_id'
  include Openmrs
	
	before_save :before_create
end
