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

      @users = User.all.collect{|user|
        user if !user.person.blank?
      }.compact

      @session_date = session[:datetime].to_date rescue Date.today
      @kit_types = Kit.find_all_by_status("active").map(&:name)

      @input_controls = [["Kit type", {"type" => "list",
                                      "options" => @kit_types}],
                         ["Lot number", {"type" => "text"}],
                         ["Quantity", {"type" => "number", "min" => 1}]
                         ]

    render layout: false
  end
end
