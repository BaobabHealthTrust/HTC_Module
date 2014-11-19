class User < ActiveRecord::Base
  include Openmrs

  before_save :encrypt_password, :before_create

  has_many :user_roles, foreign_key: "user_id", dependent: :destroy
  belongs_to :person, -> { where voided: 0 }, foreign_key: :person_id
  has_many :user_properties, foreign_key: :user_id # no default scope
  has_one :activities_property, -> { where('property = ?', 'Activities') }, class_name: 'UserProperty',
          foreign_key: :user_id

  #cattr_accessor :current_user_id

  def encrypt_password
    self.salt = BCrypt::Engine.generate_salt
    self.password = BCrypt::Engine.hash_secret(password, salt)
  end

  def self.authenticate(username, password)

    user = User.where(username: username).first
    if user && user.password == BCrypt::Engine.hash_secret(password, user.salt)
      user
    else
      nil
    end
  end

  def self.current
    if self.current_user_id
      User.find(self.current_user_id)
    else
      nil
    end
  end

  def first_name
    self.person.names.first.given_name rescue ''
  end

  def last_name
    self.person.names.first.family_name rescue ''
  end

  def name
    name = self.person.names.first
    "#{name.given_name} #{name.family_name}" rescue ""
  end

  def self.current_user_id
    Thread.current[:user]
  end

  def self.current_user_id=(user_id)
    Thread.current[:user] = user_id
  end

  def self.current
    self.find(self.current_user_id)
  end

  def remaining_stock_by_type(kit_type = nil, date = Date.today, users = [], type = "closing", locs = [])
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
      kits = Kit.all.map(&:id)
    else
      kits = [Kit.find_by_name(kit_type).id]
    end

    users << self.user_id

    plus_types = ["Distribution"].collect { |iv_name| InventoryType.find_by_name(iv_name).id }
    minus_types = ["Expires", "Losses", "Usage",].collect { |iv_name| InventoryType.find_by_name(iv_name).id }

    CouncillorInventory.find_by_sql(
          ["SELECT ci.id, ci.value_numeric, ci.inventory_type FROM councillor_inventory ci
            INNER JOIN inventory iv ON ci.voided = 0 AND iv.voided = 0 AND iv.lot_no = ci.lot_no
            AND iv.kit_type IN (?) AND DATE(iv.date_of_expiry) > ? AND DATE(ci.encounter_date) #{eq} ?
          WHERE ci.councillor_id IN (?) AND ci.location_id IN (?) GROUP BY ci.id, ci.councillor_id",
           kits, date.to_date, date.to_date, users, locs]).each do |iv|
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
      kits = Kit.all.map(&:id)
    else
      kits = [Kit.find_by_name(kit_type).id]
    end

    lot_numbers = Inventory.find_by_sql(["SELECT lot_no FROM inventory WHERE
                DATE(encounter_date) <= ? AND voided = 0 AND kit_type IN (?)", end_date, kits]).map(&:lot_no)
    type = InventoryType.where(name: 'Distribution').first

    CouncillorInventory.find_by_sql([
              "SELECT ci.encounter_date AS date, SUM(ci.value_numeric) AS sum
              FROM councillor_inventory ci
                WHERE ci.lot_no IN (?)
                  AND ci.inventory_type = ?
                  AND (DATE(ci.encounter_date) BETWEEN ? AND ?)
                  AND ci.councillor_id = ? AND ci.location_id IN (?)
              GROUP BY date",
     lot_numbers, type.id, start_date.to_date, end_date.to_date, self.user_id, locs]
    ).collect{|v| result[v.date.strftime("%d %B")] = v.sum}
    result
  end

  def losses(kit_type, start_date, end_date, locs, loss_categories)
    result = {};

    #build global space for empty variables
    loss_categories = ["Damaged", "Other use"] if loss_categories.blank?
    if locs.blank? || (locs.length == 1 && locs.first == 0)
      htc_tags = ["HTC Counseling Room","Other HTC Room"]
      htc_tags = htc_tags.map{|l| LocationTag.find_by_name(l).location_tag_id}
      locs = Location.joins(:location_tag_maps)
      .where(:location_tag_map => {:location_tag_id => htc_tags}).map{|l| l.id}
    end

    if kit_type.blank?
      kits = Kit.all.map(&:id)
    else
      kits = [Kit.find_by_name(kit_type).id]
    end

    lot_numbers = Inventory.find_by_sql(["SELECT lot_no FROM inventory WHERE
                DATE(encounter_date) <= ? AND voided = 0 AND kit_type IN (?)", end_date, kits]).map(&:lot_no)
    type = InventoryType.where(name: 'Losses').first

    CouncillorInventory.find_by_sql([
              "SELECT ci.encounter_date AS date, SUM(ci.value_numeric) AS sum
              FROM councillor_inventory ci
                WHERE ci.lot_no IN (?)
                  AND ci.inventory_type = ?
                  AND (DATE(ci.encounter_date) BETWEEN ? AND ?)
                  AND ci.councillor_id = ? AND ci.location_id IN (?)
                  AND ci.value_text IN (?)
              GROUP BY date", lot_numbers, type.id, start_date.to_date, end_date.to_date, self.user_id, locs, loss_categories]
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
      kits = Kit.all.map(&:id)
    else
      kits = [Kit.find_by_name(kit_type).id]
    end

    lot_numbers = Inventory.find_by_sql(["SELECT lot_no FROM inventory WHERE
                DATE(encounter_date) <= ? AND voided = 0 AND kit_type IN (?)", end_date, kits]).map(&:lot_no)
    type = InventoryType.where(name: 'Usage').first

    CouncillorInventory.find_by_sql([
            "SELECT ci.encounter_date AS date, SUM(ci.value_numeric) AS sum
              FROM councillor_inventory ci
                WHERE ci.lot_no IN (?)
                  AND ci.inventory_type = ?
                  AND (DATE(ci.encounter_date) BETWEEN ? AND ?)
                  AND ci.councillor_id = ? AND ci.location_id IN (?)
              GROUP BY date", lot_numbers, type.id, start_date.to_date, end_date.to_date, self.user_id, locs]
    ).collect{|v| result[v.date.strftime("%d %B")] = v.sum}
    result
  end
end

