class CouncillorInventory < ActiveRecord::Base
	self.table_name = 'councillor_inventory'
  before_create :set_location

  include Openmrs

  def set_location
    self.location_id = Location.current_location.id if self.location_id.blank?
    self.voided = 0
  end

  def self.create_used_testkit(name, lot, date, user, setting)
     type = InventoryType.find_by_name("Usage").id

     if setting == 'couns'
      inventory = self.create(lot_no: lot, councillor_id: user.id,
                        value_text: name, value_numeric: 1, encounter_date: date,
                        inventory_type: type, creator: user.id)
     elsif setting == 'rooms'
       inventory = self.create(lot_no: lot, room_id: Location.current_location.id,
                               value_text: name, value_numeric: 1, encounter_date: date,
                               inventory_type: type, creator: user.id)
     end

  end

  def self.transaction_sums(kit, inv_types, start_date, end_date)
    inv_type = InventoryType.find_by_sql(["SELECT id FROM inventory_type WHERE name IN (?)",
                                          inv_types]).map(&:id)

    kit_typesA = []
    kit_typesB = []
    if kit.blank?
      kit_typesA = Kit.all.map(&:id)
      kit_typesB = ["Negative Serum", "Positive Serum", "Negative DTS", "Positive DTS"]
    else
      kit.each do |k|
        kt = Kit.find_by_name(k)
        if kt.blank?
          kit_typesB << k
        else
          kit_typesA << kt.id
        end

      end
    end
    kit_sum = Inventory.find_by_sql(["(SELECT SUM(ci.value_numeric) AS total, DATE(ci.encounter_date) AS date, ci.lot_no,
                            iv.kit_type AS type, DATE(iv.date_of_expiry) AS exp_date FROM councillor_inventory ci
                          INNER JOIN  inventory iv ON iv.lot_no = ci.lot_no AND iv.inventory_type = ?
                          WHERE ci.inventory_type IN (?)
                            AND (DATE(ci.encounter_date) BETWEEN ? AND ?)
                            AND ci.voided = 0 AND iv.kit_type IN (?)
                          GROUP BY type, ci.lot_no, date)

                          UNION

                          (SELECT SUM(ci.value_numeric) AS total, DATE(ci.encounter_date) AS date, ci.lot_no,
                            iv.value_text AS type, DATE(iv.date_of_expiry) AS exp_date FROM councillor_inventory ci
                          INNER JOIN  inventory iv ON iv.lot_no = ci.lot_no AND iv.inventory_type = ?
                          WHERE ci.inventory_type IN (?)
                            AND (DATE(ci.encounter_date) BETWEEN ? AND ?)
                            AND ci.voided = 0 AND ci.value_text IN (?)
                          GROUP BY type, ci.lot_no, date)
                          ",
                                     InventoryType.where(name: "Delivery").first.id,
                                     inv_type, start_date.to_date, end_date.to_date, kit_typesA,
                                     InventoryType.where(name: "Serum Delivery").first.id,
                                     inv_type, start_date.to_date, end_date.to_date, kit_typesB])
    kit_sum
  end
end
