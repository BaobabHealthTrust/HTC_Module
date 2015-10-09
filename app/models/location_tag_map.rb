class LocationTagMap < ActiveRecord::Base
	self.table_name = 'location_tag_map'
  self.primary_keys = 'location_id', 'location_tag_id'

	include Openmrs
	before_save :before_create
  belongs_to :location, -> { where retired: 0}, foreign_key: "location_id" 
  belongs_to :location_tag, ->{ where retired: 0}, foreign_key: "location_tag_id" 
end
