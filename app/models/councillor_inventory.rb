class CouncillorInventory < ActiveRecord::Base
	self.table_name = 'councillor_inventory'
  before_create :set_location

  include Openmrs

  def set_location
    self.location_id = Location.current_location.id if self.location_id.blank?
    self.voided = 0
  end

  def self.create_used_testkit(name, lot, date, user)
     type = InventoryType.find_by_name("Usage").id

     inventory = self.create(lot_no: lot, councillor_id: user.id,
                        value_text: name, value_numeric: 1, encounter_date: date,
                        inventory_type: type, creator: user.id)
  end
end
