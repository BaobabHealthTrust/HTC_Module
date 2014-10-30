class InventoryController < ApplicationController

  def options
    render layout: false
  end

  def new_batch
    @kits = Kit.find_all_by_status("active")

    @input_controls = [["Date of delivery", {"type" => "date"}],
                       ["Lot number", {"type" => "text"}],
                       ["Quantity", {"type" => "number", "min" => 1}],
                       ["Date of expiry", {"type" => "date"}]]
    render layout: false
  end

  def edit
    @kits = Kit.find_all_by_status("active")

    @input_controls = [["Lot number", {"type" => "text"}],
                       ["Quantity", {"type" => "number"}]]
    render layout: false
  end

  def create
    captured_data = params[:data];
    type = InventoryType.find_by_name("Delivery").id
    session_date = session[:datetime].to_date rescue Date.today

    captured_data.each do |kit_name, opts|
      kit_type = Kit.find_by_name(kit_name).id;

      opts.each do |value|
        encounter_date = value["Date of delivery"].to_date
        lot_number = value["Lot number"]
        qty = value["Quantity"].to_i
        exp_date = value["Date of expiry"].to_date

        Inventory.create(lot_no: lot_number,
                         kit_type: kit_type,
                         value_date: encounter_date,
                         value_numeric: qty,
                         inventory_type: type,
                         date_of_expiry: exp_date,
                         encounter_date: session_date,
                         voided: false,
                         creator: current_user.id
        )
      end
    end
    redirect_to '/htcs?tab=admin'
  end

  def distribute
    @session_date = session[:datetime].to_date rescue Date.today

    if request.post?
      captured_data = params[:data] || []
      type = InventoryType.find_by_name("Distribution").id

      captured_data.each do |username, opts|

        assignee_id = User.find_by_username(username).id;

        opts.each do |value|
          type_name = value["Kit type"]
          lot_number = value["Lot number"]
          qty = value["Quantity"].blank??  "" : value["Quantity"].to_i

          if(!type_name.blank? && !lot_number.blank? && !qty.blank?)
            CouncillorInventory.create(lot_no: lot_number,
                             value_numeric: qty,
                             value_text: type_name,
                             councillor_id: assignee_id,
                             inventory_type: type,
                             encounter_date: @session_date,
                             voided: false,
                             creator: current_user.id
            )
          end
        end
      end

      redirect_to '/htcs?tab=admin' and return
    end

      @users = User.all.collect{|user|
        user if !user.person.blank?
      }.compact

      @kit_types = Kit.find_all_by_status("active").map(&:name)

      @input_controls = [["Kit type", {"type" => "list",
                                      "options" => @kit_types}],
                         ["Lot number", {"type" => "text"}],
                         ["Quantity", {"type" => "number",
                                       "min" => 1}]
                         ]

    render layout: false
  end

  def validate_dist

   #initialize default messages
    result = {}
    result["Lot number"] = {}
    result["Quantity"] = {}
    result["Kit type"] = {}

    result["Kit type"]["warning"] = ""
    result["Kit type"]["info"] = ""

    result["Lot number"]["warning"] = ""
    result["Lot number"]["info"] = ""

    result["Quantity"]["warning"] = ""
    result["Quantity"]["info"] = ""

    plus_types = ["Delivery"].collect{|iv_name| InventoryType.find_by_name(iv_name).id}
    minus_types = ["Distribution", "Expires", "Losses", "Usage", ].collect{|iv_name| InventoryType.find_by_name(iv_name).id}

    user = User.find_by_username(params[:username]) rescue nil
    session_date = session[:datetime].to_date rescue Date.today
    kit_name = params[:kit_type]
    lot_number = params[:lot_number]
    qty = params[:qty].to_i
    ui_sum = params[:ui_sum].to_i
    ui_sum_exc = ui_sum - qty
    qty_sum = 0
    user_sum = 0

    if !user.blank?
      user_sum = user.remaining_stock_by_type(kit_name, session_date)
    end
    result["Kit type"]["warning"] = ""

    if user_sum.to_i > 0
      result["Kit type"]["info"] = " #{user.username rescue ''} already has <span style='color: blue; font-weight: bold; '>#{user_sum}</span> #{kit_name.downcase} kits in stock"
    else
      result["Kit type"]["info"] = " #{user.username rescue ''} has <span style='color: blue; font-weight: bold; '> no </span> assigned  #{kit_name.downcase} stock"
    end

    if !params[:kit_type].blank? && !params[:lot_number].blank?

      ivs = Inventory.find_by_sql(["SELECT value_numeric, inventory_type FROM inventory
                WHERE kit_type = ? AND lot_no = ?", Kit.find_by_name(kit_name).id, lot_number])

      ivs2 = CouncillorInventory.find_by_sql(["SELECT ci.id, ci.value_numeric, ci.inventory_type FROM councillor_inventory ci
             JOIN inventory iv ON  iv.lot_no = ci.lot_no
          WHERE iv.voided = 0 AND ci.voided =0 AND iv.kit_type = ? AND iv.lot_no = ? GROUP BY ci.id", Kit.find_by_name(kit_name).id, lot_number])

      if ivs.blank?

        result["Lot number"]["warning"] = "Does not exist!"
        result["Quantity"]["warning"] = "N/A!"
      else

        (ivs + ivs2).each do |iv|
          if plus_types.include?(iv.inventory_type)
            qty_sum = qty_sum + iv.value_numeric.to_i
          elsif minus_types.include?(iv.inventory_type)
            qty_sum = qty_sum - iv.value_numeric.to_i
          end
        end

        result["Quantity"]["info"] = "<span style='color: blue; font-weight: bold; '> #{qty_sum - ui_sum_exc}</span> unassigned"

        if (qty_sum - ui_sum_exc) < qty
          result["Quantity"]["warning"] = "Limited stock!"
        else
          result["Quantity"]["warning"] = ""
        end
      end
    end

    render text: result.to_json
  end

  def losses
    @session_date = session[:datetime].to_date rescue Date.today
    captured_data = params[:data] || []
    type = InventoryType.find_by_name("Losses").id

    captured_data.each do |kit_name, opts|

        opts.each do |value|
          lot_number = value["Lot number"]
          qty = value["Quantity"].blank??  "" : value["Quantity"].to_i

          if(!lot_number.blank? && !qty.blank? && qty > 0)
            Inventory.create(lot_no: lot_number,
                                       value_numeric: qty,
                                       inventory_type: type,
                                       encounter_date: @session_date,
                                       voided: false,
                                       creator: current_user.id
            )
          end
      end
    end

    redirect_to '/htcs?tab=admin'
  end

  def stock_levels
    @location = Location.current_location;
    @user = current_user
  end
end
