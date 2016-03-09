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

  def remaining_stock_by_type(kit_type = nil, date = Date.today, rooms = [], type = "closing", locs = [])
    result = 0
    eq = "<="
    eq = "<" if (type == "opening")

    if locs.blank? || (locs.length == 1 && locs.first == 0)
      htc_tags = ["HTC Counseling Room","Other HTC Room"]
      htc_tags = htc_tags.map{|l| LocationTag.find_by_name(l).location_tag_id}
      locs = Location.joins(:location_tag_maps)
      .where(:location_tag_map => {:location_tag_id => htc_tags}).map{|l| l.id}
    end

    if kit_type.blank?
      kits = Kit.all.map(&:name) + ["Positive Serum", "Negative Serum", "Positive DTS", "Negative DTS"]
    else
      kits = kit_type
    end

    rooms << self.id

    plus_types = ["Distribution"].collect { |iv_name| InventoryType.find_by_name(iv_name).id }
    minus_types = ["Expires", "Losses", "Usage"].collect { |iv_name| InventoryType.find_by_name(iv_name).id }

    CouncillorInventory.find_by_sql(
        ["SELECT ci.id, ci.value_numeric, ci.inventory_type FROM councillor_inventory ci
          WHERE ci.value_text IN (?)  AND DATE(ci.encounter_date) #{eq} ?
          AND ci.room_id IN (?) AND ci.location_id IN (?) GROUP BY ci.id, ci.room_id",
         kits, date.to_date, rooms, locs]).each do |iv|
      if plus_types.include?(iv.inventory_type)
        result = result + iv.value_numeric.to_i
      elsif minus_types.include?(iv.inventory_type)
        result = result - iv.value_numeric.to_i
      end
    end
    result
  end

  def receipts(kit_type, start_date, end_date, locs)
    result = {}

    if locs.blank? || (locs.length == 1 && locs.first == 0)
      htc_tags = ["HTC Counseling Room","Other HTC Room"]
      htc_tags = htc_tags.map{|l| LocationTag.find_by_name(l).location_tag_id}
      locs = Location.joins(:location_tag_maps)
      .where(:location_tag_map => {:location_tag_id => htc_tags}).map{|l| l.id}
    end

    if kit_type.blank?
      kits = Kit.all.map(&:name) + ["Positive Serum", "Negative Serum", "Positive DTS", "Negative DTS"]
    else
      kits = [kit_type]
    end

    type = InventoryType.where(name: 'Distribution').first

    CouncillorInventory.find_by_sql([
                                        "SELECT ci.encounter_date AS date, SUM(ci.value_numeric) AS sum
              FROM councillor_inventory ci
                WHERE value_text IN (?)
                  AND ci.inventory_type = ?
                  AND (DATE(ci.encounter_date) BETWEEN ? AND ?)
                  AND ci.room_id = ? AND ci.location_id IN (?)
              GROUP BY date",
                                        kits, type.id, start_date.to_date, end_date.to_date, self.id, locs]
    ).collect{|v| result[v.date.strftime("%d %B")] = v.sum}
    result
  end

  def losses(kit_type, start_date, end_date, locs, loss_categories)
    result = {};

    #build global space for empty variables
    loss_categories = ["Damaged", "Other use"] if loss_categories.blank?
    if locs.blank? || (locs.length == 1 && locs.first == 0)
      htc_tags = ["HTC Counseling Room"]
      htc_tags = htc_tags.map{|l| LocationTag.find_by_name(l).location_tag_id}
      locs = Location.joins(:location_tag_maps)
      .where(:location_tag_map => {:location_tag_id => htc_tags}).map{|l| l.id}
    end

    if kit_type.blank?
      kits = Kit.all.map(&:name) + ["Positive Serum", "Negative Serum", "Positive DTS", "Negative DTS"]
    else
      kits = [kit_type]
    end

    type = InventoryType.where(name: 'Losses').first

    CouncillorInventory.find_by_sql([
                                        "SELECT ci.encounter_date AS date, SUM(ci.value_numeric) AS sum
              FROM councillor_inventory ci
                WHERE ci.value_text IN (?)
                  AND ci.inventory_type = ?
                  AND (DATE(ci.encounter_date) BETWEEN ? AND ?)
                  AND ci.room_id = ? AND ci.location_id IN (?)
                  AND ci.comments IN (?)
              GROUP BY date", kits, type.id, start_date.to_date, end_date.to_date, self.id, locs, loss_categories]
    ).collect{|v| result[v.date.strftime("%d %B")] = v.sum}
    result
  end

  def client_tests(kit_type, start_date, end_date, locs)
    result = {}
    if locs.blank? || (locs.length == 1 && locs.first == 0)
      htc_tags = ["HTC Counseling Room","Other HTC Room"]
      htc_tags = htc_tags.map{|l| LocationTag.find_by_name(l).location_tag_id}
      locs = Location.joins(:location_tag_maps)
      .where(:location_tag_map => {:location_tag_id => htc_tags}).map{|l| l.id}
    end

    if kit_type.blank?
      kits = Kit.all.map(&:name) + ["Positive Serum", "Negative Serum", "Positive DTS", "Negative DTS"]
    else
      kits = [kit_type]
    end

    type = InventoryType.where(name: 'Usage').first

    CouncillorInventory.find_by_sql([
                                        "SELECT ci.encounter_date AS date, SUM(ci.value_numeric) AS sum
              FROM councillor_inventory ci
                WHERE ci.value_text IN (?)
                  AND ci.inventory_type = ?
                  AND (DATE(ci.encounter_date) BETWEEN ? AND ?)
                  AND ci.room_id = ? AND ci.location_id IN (?)
              GROUP BY date", kits, type.id, start_date.to_date, end_date.to_date, self.id, locs]
    ).collect{|v| result[v.date.strftime("%d %B")] = v.sum}
    result
  end

end
