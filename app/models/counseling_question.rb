class CounselingQuestion < ActiveRecord::Base
  self.table_name = 'counseling_question'
  self.primary_key = 'question_id'
	self.default_scope -> {  where("retired = ? OR retired = ?", 0, 1)  }
	scope :active_list, lambda { where("retired = ?", 0) }  

end
