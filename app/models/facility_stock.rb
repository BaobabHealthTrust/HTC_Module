class FacilityStock < ActiveRecord::Base

  def remaining_stock_by_type(kit_type = nil, date = Date.today, type = "closing", locs = [])
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

    plus_types = ["Distribution"].collect { |iv_name| InventoryType.find_by_name(iv_name).id }
    minus_types = ["Expires", "Losses", "Usage",].collect { |iv_name| InventoryType.find_by_name(iv_name).id }

    CouncillorInventory.find_by_sql(
          ["SELECT ci.id, ci.value_numeric, ci.inventory_type FROM councillor_inventory ci
            INNER JOIN inventory iv ON ci.voided = 0 AND iv.voided = 0 AND iv.lot_no = ci.lot_no
            AND iv.kit_type IN (?) AND DATE(iv.date_of_expiry) > ? AND DATE(ci.encounter_date) #{eq} ?
          WHERE  ci.location_id IN (?) GROUP BY ci.id, ci.councillor_id",
           kits, date.to_date, date.to_date, locs]).each do |iv|
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
                  AND ci.location_id IN (?)
              GROUP BY date",
     lot_numbers, type.id, start_date.to_date, end_date.to_date, locs]
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
                  AND ci.location_id IN (?)
                  AND ci.value_text IN (?)
              GROUP BY date", lot_numbers, type.id, start_date.to_date, end_date.to_date, locs, loss_categories]
    ).collect{|v| result[v.date.strftime("%d %B")] = v.sum}
    result
  end

end
