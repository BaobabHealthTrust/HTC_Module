class ChildProtocol < ActiveRecord::Base
  self.table_name = 'child_protocol'
	self.primary_key = 'child_id'
end
