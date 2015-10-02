class Inventory < ActiveRecord::Base
	self.table_name = 'inventory'
  before_create :set_location

  include Openmrs
	
  def self.stock_levels(users, locs, year= Date.today.year, month = Date.today.month)

    date = Date.new(year, month)
    i = date.end_of_month
    dates = []

    while i >= date.beginning_of_month
      dates << i.to_date
      i -= 1.day
    end
    dates.reverse!

    @users = users
    @tests = Kit.where(status: 'active')

    result = {}
    dates.each do |date|
        result[date] = {} if result[date].blank?
        @users.each do |user|
          result[date][user.username] = {} if result[date][user.username].blank?
          @tests.each do |test|
            result[date][user.username][test.name] = {} if result[date][user.username][test.name].blank?
              locs.each do |l|
                result[date][user.username][test.name][l.name] = {} if result[date][user.username][test.name][l.name].blank?
                result[date][user.username][test.name][l.name]["opening_stock"] = user.remaining_stock_by_type(test.name, date, [], 'opening', l.id)
                result[date][user.username][test.name][l.name]["closing_stock"] = user.remaining_stock_by_type(test.name, date, [], "closing",  l.id)
                result[date][user.username][test.name][l.name]["receipts"] = user.receipts( test.name, date, Location.current_location.id)
              end
          end
        end
    end
    result
  end

  def set_location
    self.location_id = Location.current_location.id if self.location_id.blank?
  end

  def self.transaction_sums(kit, inv_types, start_date, end_date)
    inv_type = InventoryType.find_by_sql(["SELECT id FROM inventory_type WHERE name IN (?)",
                                         inv_types]).map(&:id)

    kit_typesA = []
    kit_typesB = []
    if kit.blank?
      kit_typesA = Kit.all.map(&:id)
      kit_typesB = ["Negative", "Positive"]
    else
      kit.each do |k|
        kk = Kit.where(name: k).first rescue nil
        kit_typesA << kk.id if !kk.blank?
        kit_typesB << k if kk.blank?
      end
    end

    kit_sum = Inventory.find_by_sql(["SELECT SUM(value_numeric) AS total, DATE(encounter_date) AS date,
                          lot_no, COALESCE(kit_type, value_text) AS type, MAX(DATE(date_of_expiry)) AS exp_date FROM inventory
                          WHERE inventory_type IN (?)
                          AND (DATE(encounter_date) BETWEEN ? AND ?)
                          AND voided = 0 AND (kit_type IN (?) OR value_text IN (?))
                          GROUP BY type, lot_no, date ",
                           inv_type, start_date.to_date, end_date.to_date, kit_typesA, kit_typesB])
    kit_sum
  end

  def self.remaining_sum(date, lot_number, type)
    del_type = InventoryType.where(name: "Delivery").first.id
    dist_type = InventoryType.where(name: "Distribution").first.id
    damages_type = InventoryType.where(name: "Damages")

    if Kit.where(name: type).blank?
       del_type = InventoryType.where(name: "Serum Delivery")
    end

    deliveries = Inventory.find_by_sql(["SELECT SUM(value_numeric) AS total FROM inventory
                                          WHERE inventory_type = ? AND voided = 0 AND lot_no = ?
                                          AND DATE(encounter_date) <= ? AND DATE(date_of_expiry) > ?",
                                        del_type, lot_number, date, date
                                       ]).first.total.to_i

    damages =  Inventory.find_by_sql(["SELECT SUM(value_numeric) AS total FROM inventory
                                          WHERE inventory_type = ? AND voided = 0 AND lot_no = ?
                                          AND DATE(encounter_date) <= ? AND DATE(date_of_expiry) > ?",
                                      damages_type, lot_number, date, date
                                     ]).first.total.to_i

    distribution =  Inventory.find_by_sql(["SELECT SUM(ci.value_numeric) AS total FROM councillor_inventory ci
                          INNER JOIN  inventory iv ON iv.lot_no = ci.lot_no AND iv.inventory_type = ?
                          WHERE ci.inventory_type = ?
                            AND DATE(ci.encounter_date) <= ?
                            AND ci.voided = 0 AND ci.lot_no = ?
                            AND DATE(iv.date_of_expiry) > ?
                          GROUP BY ci.id
                          ", del_type, dist_type, date.to_date, lot_number, date.to_date]).map(&:total).sum

    return (deliveries.to_i - (damages.to_i + distribution.to_i))

    return "N/A"
  end
end
