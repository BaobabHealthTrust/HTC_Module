class Village < ActiveRecord::Base
	self.table_name = "villages"
	self.primary_key = "village_id"

	belongs_to :traditional_authority
end
