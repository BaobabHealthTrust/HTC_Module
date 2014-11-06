class CouncillorInventory < ActiveRecord::Base
	self.table_name = 'councillor_inventory'
  before_create :set_location

  include Openmrs

  def set_location
    self.location_id = Location.current_location.id if self.location_id.blank?
  end
end
