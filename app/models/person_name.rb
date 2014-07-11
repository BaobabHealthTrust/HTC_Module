class PersonName < ActiveRecord::Base
		self.table_name = 'person_name'
		include Openmrs

		before_save :before_create
end
