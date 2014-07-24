class UserRole < ActiveRecord::Base
	self.table_name = 'user_role'

	include Openmrs
	before_save :before_create
	belongs_to :user, -> { where retired: 0}, foreign_key: "user_id"
end
