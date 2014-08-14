class Location < ActiveRecord::Base
	self.table_name = 'location'

	include Openmrs
	before_save :before_create
  has_many :location_tag_maps, foreign_key: "location_id", dependent: :destroy
  
  cattr_accessor :login_rooms_details
  
  def initialize
    self.login_rooms_details = {} if self.login_rooms_details.nil?
  end
end
