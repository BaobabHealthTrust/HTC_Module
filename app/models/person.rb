class Person < ActiveRecord::Base
		self.table_name = 'person'
		include Openmrs

		before_save :before_create
end
