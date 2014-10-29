class CouncillorInventory < ActiveRecord::Base
	self.table_name = 'councillor_inventory'

  include Openmrs

end
