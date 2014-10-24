class Inventory < ActiveRecord::Base
	self.table_name = 'inventory'

  include Openmrs

end
