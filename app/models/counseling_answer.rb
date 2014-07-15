class CounselingAnswer < ActiveRecord::Base
  self.table_name = 'counseling_answer'
  self.primary_key = 'answer_id'
  include Openmrs
	
	before_save :before_create
end
