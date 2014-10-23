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
end
