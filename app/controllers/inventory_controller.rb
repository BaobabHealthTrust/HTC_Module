class InventoryController < ApplicationController

  def options
    render layout: false
  end

  def new_batch
    @user = current_user
    @location = Location.current_location
    @kits = Kit.find_all_by_status("active")

    @session_date = session[:datetime].to_date rescue Date.today

    @input_controls = [["Date of delivery", {"type" => "date",
                                             "min" => @session_date}],
                       ["Lot number", {"type" => "text"}],
                       ["Quantity", {"type" => "number", "min" => 1}],
                       ["Date of expiry", {"type" => "date",
                                           "min" => @session_date}]]
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
    redirect_to htcs_path
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
          qty = value["Quantity"].to_i

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

      redirect_to htcs_path and return
    end

      @users = User.all.collect{|user|
        user if !user.person.blank?
      }.compact

      @kit_types = Kit.find_all_by_status("active").map(&:name)

      @input_controls = [["Kit type", {"type" => "list",
                                      "options" => @kit_types,
                                      "validation_link" => "/inventory/validate?type=distribution?type=ktype"}],
                         ["Lot number", {"type" => "text", "validation_link" => "/inventory/validate_dist?type=lot"
                         }],
                         ["Quantity", {"type" => "number",
                                       "min" => 1,
                                       "validation_link" => "/inventory/validate?type=distribution?type=qty"}]
                         ]

    render layout: false
  end

  def validate_dist

   #initialize default messages
    result = {}
    result["Lot number"] = {}
    result["Quantity"] = {}

    result["Lot number"]["warning"] = ""
    result["Lot number"]["info"] = ""

    result["Quantity"]["warning"] = ""
    result["Quantity"]["info"] = ""

    if !params[:kit_type].blank? && !params[:lot_number].blank?
      kit_name = params[:kit_type]
      lot_number = params[:lot_number]
      qty = params[:qty].to_i

      ivs = Inventory.where(kit_type: Kit.find_by_name(kit_name).id,
                            lot_no: lot_number)

      if ivs.blank?
        result["Lot number"]["warning"] = "Does not exist!"
        result["Quantity"]["warning"] = "N/A"
      else
        qty_sum = 0
        ivs.each do |iv|
          qty_sum = qty_sum + iv.value_numeric.to_i
        end

        result["Quantity"]["info"] = "#{qty_sum} available"

        if qty_sum < qty
          result["Quantity"]["warning"] = "Limited stock!"
        else
          result["Quantity"]["warning"] = ""
        end
      end
    end

    render text: result.to_json
  end
end
