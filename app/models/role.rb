class Role < ActiveRecord::Base
	self.table_name = 'role'

	include Openmrs
	before_save :before_create
end
