class Location < ActiveRecord::Base
	self.table_name = 'location'

	include Openmrs
	before_save :before_create
  has_many :location_tag_maps, foreign_key: "location_id", dependent: :destroy
  
  cattr_accessor :login_rooms_details
  
  def self.current_location_id
  	Thread.current[:location_id]
  end
  

  def self.current_location_id=(location_id)
    Thread.current[:location_id] = location_id
  end
  
	def self.current_location
		self.find(self.current_location_id)
	end

end
