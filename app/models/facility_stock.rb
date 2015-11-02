class FacilityStock < ActiveRecord::Base

  def self.remaining_stock_by_type(kit_type = nil, date = Date.today, type = "closing", locs = [])
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
          WHERE  ci.location_id IN (?) GROUP BY ci.id",
           kits, date.to_date, date.to_date, locs]).each do |iv|
            if plus_types.include?(iv.inventory_type)
              result = result + iv.value_numeric.to_i
            elsif minus_types.include?(iv.inventory_type)
              result = result - iv.value_numeric.to_i
            end
    end
    result
  end

  def self.receipts(kit_type, start_date, end_date, locs=[])
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

    result = CouncillorInventory.find_by_sql([
              "SELECT SUM(ci.value_numeric) AS sum
              FROM councillor_inventory ci
                WHERE ci.lot_no IN (?)
                  AND ci.value_numeric IS NOT NULL
                  AND ci.inventory_type = ?
                  AND (DATE(ci.encounter_date) BETWEEN ? AND ?)
                  AND ci.location_id IN (?)",
     lot_numbers, type.id, start_date.to_date, end_date.to_date, locs]
    ).map{|v|  v.sum}
  end

  def self.client_usage(kit_type, start_date, end_date, locs=[])
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

    result = CouncillorInventory.find_by_sql([
              "SELECT SUM(ci.value_numeric) AS sum
              FROM councillor_inventory ci
                WHERE ci.lot_no IN (?)
                  AND ci.inventory_type = ?
                  AND (DATE(ci.encounter_date) BETWEEN ? AND ?)
                  AND ci.location_id IN (?)",
     lot_numbers, type.id, start_date.to_date, end_date.to_date, locs]
    ).map{|v|  v.sum}

  end

  def self.proficiency_usage(kit_type, start_date, end_date, name)
     result = {}
    value_id = ConceptName.where(name: name).first.concept_id
    concept_id = ConceptName.where("name ='Kit Lot Number'").first.concept_id
    proficiency = TestObservation.find_by_sql([
                         "SELECT count(value_text) as v FROM test_observation
                         WHERE concept_id = ? AND value_group_id = ? AND DATE(obs_datetime) >= ?
                        AND DATE(obs_datetime) <= ? AND voided = 0",
                        concept_id, value_id, start_date, end_date]).first.v rescue 0

     if kit_type.blank?
      kits = Kit.all.map(&:id)
    else
      kits = [Kit.find_by_name(kit_type).id]
    end

    lot_numbers = Inventory.find_by_sql(["SELECT lot_no FROM inventory WHERE
                DATE(encounter_date) <= ? AND voided = 0 AND kit_type IN (?)", end_date, kits]).map(&:lot_no)

    quality = TestObservation.find_by_sql(["
                        SELECT COUNT(*) as v FROM test_observation
                        WHERE value_text IN (SELECT distinct(lot_no) 
                                            FROM inventory WHERE inventory_type = (SELECT id FROM inventory_type WHERE name = 'Delivery')
                        ) 
                        AND obs_datetime BETWEEN ? AND ?", start_date, end_date]).first.v rescue 0

=begin
    quality = TestObservation.find_by_sql(["
                        SELECT count(t.value_text) as v FROM test_observation t
                        INNER JOIN inventory i ON i.lot_no = t.value_text
                        WHERE t.voided =0  AND DATE(obs_datetime) >= ?
                        AND DATE(obs_datetime) <= ? AND i.lot_no IN (?)",
                        start_date, end_date, lot_numbers]).first.v rescue 0 
=end
      return (proficiency.to_i + quality.to_i)
  end

  def self.losses(kit_type, start_date, end_date, locs=[], loss_categories=[])
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

    result = CouncillorInventory.find_by_sql([
             "SELECT  SUM(ci.value_numeric) AS sum
              FROM councillor_inventory ci
                WHERE ci.lot_no IN (?)
                  AND ci.inventory_type = ?
                  AND (DATE(ci.encounter_date) BETWEEN ? AND ?)
                  AND ci.location_id IN (?)
                  AND (ci.value_text IN (?) OR ci.comments IN (?))
             ", lot_numbers, type.id, start_date.to_date, end_date.to_date, locs, loss_categories, loss_categories]
    ).collect{|v|  v.sum}
    
  end

    def self.kits_available
    kits = []
     kit =  Kit.where(status:  'active').order(flow_order: :asc)
     (kit || []).each {|k|
        kits << [k.name]
     }
     return kits
  end

end
