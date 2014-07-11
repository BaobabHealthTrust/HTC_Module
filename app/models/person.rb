class Person < ActiveRecord::Base
		self.table_name = 'person'
		include Openmrs

		before_save :before_create

	def age(current_date = Date.today)
			age = current_date.year - birthdate.year
			age -= 1 if birthdate.strftime("%m%d").to_i > current_date.strftime("%m%d").to_i
			age
	end
end
