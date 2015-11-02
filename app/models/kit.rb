class Kit < ActiveRecord::Base
	self.table_name = 'kits'

  def self.kits_available(user)
    remaining = {}
    testing = 1
    kits = []
     kit =  self.where(status:  'active').order(flow_order: :asc)
     (kit || []).each {|k|
        remaining[k.name] = user.remaining_stock_by_type(k.name)
        next if remaining[k.name] == 0
        kits << [k.id, k.name, k.description]
     }
     testing = 0 if kits.length < kit.last.flow_order
     return kits, remaining, testing
  end
end
