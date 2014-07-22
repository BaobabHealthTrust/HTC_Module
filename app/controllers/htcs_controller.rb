class HtcsController < ApplicationController
  before_action :set_htc, only: [:show, :edit, :update, :destroy]

  def index
  	tag_id = LocationTag.find_by_name('HTC Counselling Room').id
		@rooms = Location.joins(:location_tag_maps).where("location_tag_id=?",tag_id)

		@rooms_info = {}

		@rooms.each do |r|
			@rooms_info[r.name] = {}
			@rooms_info[r.name][:max_capacity] = Random.rand(100)
			@rooms_info[r.name][:seen] = @rooms_info[r.name][:max_capacity].to_f
			@rooms_info[r.name][:waiting] = client_seen_in_room(r.name)
			@rooms_info[r.name][:available_space] = 'NaN'
			@rooms_info[r.name][:total_attendance] = 'NaN'
		end
  end

  def  client_seen_in_room(room, date=Date.today)
		   encounter_type_id = EncounterType.find_by_name('IN SESSION').id
			 Client.joins(:encounters)
		         .where("encounter_type = #{encounter_type_id} AND
		                 DATE(encounter_datetime) = ?",date).count
  end

end
