class InventoryController < ApplicationController

  def options
    render layout: false
  end

  def new_batch
    @kits = Kit.where(status: "active")
    @kit_names = @kits.map(&:name) + ["Positive serum", "Negative serum", "Positive DTS", "Negative DTS"]
    @input_controls = [["Date of delivery", {"type" => "date"}],
                       ["Lot number", {"type" => "text"}],
                       ["Quantity", {"type" => "number", "min" => 1}],
                       ["Date of expiry", {"type" => "date"}]]
    render layout: false
  end

  def physical_count
    @kits = Kit.where(status: "active").map(&:name) + ["Positive serum", "Negative serum", "Positive DTS", "Negative DTS"]

    if request.post?
      captured_data = params[:data]
      type = InventoryType.find_by_name("Physical Count").id
      session_date = session[:datetime].to_date rescue Date.today

      captured_data.each do |serum_type, opts|
        next if serum_type.blank?

        kit_type = Kit.find_by_name(serum_type).id rescue nil
        serum_name = nil
        if kit_type.blank?
          serum_name = serum_type.match(/Positive|Negative|positive|negative/i)[0] rescue nil
        end

        opts.each do |value|
          lot_number = value["Lot number"]
          qty = value["Quantity"].to_i
          exp_date = value["Date of expiry"].to_date

          next if (lot_number.blank? || exp_date.blank? || qty.blank?)
          Inventory.create(lot_no: lot_number,
                           value_numeric: qty,
                           kit_type: kit_type,
                           value_text: serum_name,
                           inventory_type: type,
                           date_of_expiry: exp_date,
                           encounter_date: session_date,
                           voided: false,
                           creator: current_user.id
          )
        end
      end

      redirect_to htcs_path and return
    end

    @input_controls = [
                       ["Lot number", {"type" => "text"}],
                       ["Quantity", {"type" => "number", "min" => 1}],
                       ["Date of expiry", {"type" => "date"}]]
    render layout: false
  end

  def edit
    @kit_names = Kit.find_all_by_status("active").map(&:name) + ["Positive serum", "Negative serum", "Positive DTS", "Negative DTS"]

    @input_controls = [["Lot number", {"type" => "text"}],
                       ["Quantity", {"type" => "number"}]]
    render layout: false
  end

  def create
    captured_data = params[:data]
    session_date = session[:datetime].to_date rescue Date.today

    captured_data.each do |kit_name, opts|
      kit_type = Kit.find_by_name(kit_name).id rescue nil
      serum_name = nil
      if kit_type.blank?
        type = InventoryType.find_by_name("Serum Delivery").id
        serum_name = kit_name
      else
        type = InventoryType.find_by_name("Delivery").id
      end

        opts.each do |value|
        encounter_date = value["Date of delivery"].to_date
        lot_number = value["Lot number"]
        qty = value["Quantity"].to_i
        exp_date = value["Date of expiry"].to_date

        next if (encounter_date.blank? || lot_number.blank? || exp_date.blank? || qty.blank?)
        Inventory.create(lot_no: lot_number,
                         kit_type: kit_type,
                         value_date: encounter_date,
                         value_text: (serum_name.match(/Positive|Negative|positive|negative/i)[0] rescue nil),
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
          qty = value["Quantity"].blank? ? "" : value["Quantity"].to_i

          if (!type_name.blank? && !lot_number.blank? && !qty.blank?)
            CouncillorInventory.create(lot_no: lot_number,
                                       value_numeric: qty,
                                       value_text: ((type_name.match(/Positive|Negative|positive|negative/i)[0] rescue type_name) || type_name),
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

    @users = User.all.collect { |user|
      user if !user.person.blank?
    }.compact

    @kit_types = Kit.find_all_by_status("active").map(&:name) + ["Positive serum", "Negative serum", "Positive DTS", "Negative DTS"]

    @input_controls = [["Kit type", {"type" => "list",
                                     "options" => @kit_types}],
                       ["Lot number", {"type" => "text"}],
                       ["Quantity", {"type" => "number",
                                     "min" => 1}]
    ]

    render layout: false
  end

  def batch_available
     lot = params[:lot_number]
     user = current_user.id
     name = params[:name]
     lot_no = CouncillorInventory.where("councillor_id = ? AND lot_no = ? AND value_text = ? ",
                                                   user, lot, name).first.lot_no rescue "none"
    render text: lot_no.to_json
  end

  def check_presence

    result = {}
    serum_no = params["serum_lot_number"]
    kit_no = params["kit_lot_number"]
    result["Serum lot number"] = {}
    result["Testkit lot number"] = {}

    result["Serum lot number"]["info"] = ""
    result["Serum lot number"]["warning"] = ""
    result["Serum lot number"]["warning"] = ((Inventory.where(lot_no: serum_no,
                                                              inventory_type:
                                                                  InventoryType.where(name: "Serum Delivery").first.id).blank? rescue true) ?
        "N/A" : "") unless serum_no.blank?

    result["Testkit lot number"]["info"] = ""
    result["Testkit lot number"]["warning"] = ""
    result["Testkit lot number"]["warning"] = ((Inventory.where(lot_no: kit_no,
                                                                inventory_type: InventoryType.where(name: "Delivery").first.id).blank? rescue true) ?
        "N/A" : "") unless kit_no.blank?

    render text: result.to_json
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

    plus_types = ["Delivery", "Serum Delivery"].collect { |iv_name| InventoryType.find_by_name(iv_name).id }
    minus_types = ["Distribution", "Expires", "Losses", "Usage",].collect { |iv_name| InventoryType.find_by_name(iv_name).id }

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
      user_sum = user.remaining_stock_by_type(kit_name, session_date) rescue 0
    end
    result["Kit type"]["warning"] = ""

    if user_sum.to_i > 0
      result["Kit type"]["info"] = " #{user.username rescue ''} already has <span style='color: blue; font-weight: bold; '>#{user_sum}</span> #{kit_name.downcase} kits in stock"
    else
      result["Kit type"]["info"] = " #{user.username rescue ''} has <span style='color: blue; font-weight: bold; '> no </span> assigned  #{kit_name.downcase} stock"
    end

    if !params[:kit_type].blank? && !params[:lot_number].blank?

      ivs = Inventory.find_by_sql(["SELECT value_numeric, inventory_type FROM inventory
                WHERE voided = 0 AND (kit_type = ? OR value_text = ?) AND lot_no = ?",
                                   (Kit.find_by_name(kit_name).id rescue nil),
                                   (kit_name.match(/Positive|Negative|positive|negative/i)[0] rescue nil),
                                   lot_number])

      ivs2 = CouncillorInventory.find_by_sql(["SELECT ci.id, ci.value_numeric, ci.inventory_type FROM councillor_inventory ci
             JOIN inventory iv ON  iv.lot_no = ci.lot_no
          WHERE iv.voided = 0 AND ci.voided =0 AND (iv.kit_type = ? OR iv.value_text = ?) AND iv.lot_no = ? GROUP BY ci.id",
                                              (Kit.find_by_name(kit_name).id rescue nil),
                                              (kit_name.match(/Positive|Negative|positive|negative/i)[0] rescue nil),
                                              lot_number])

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
      kit_text = nil
      kit_type = Kit.where(name: kit_name).first.id rescue nil
      kit_text = kit_name.match(/Negative|Positive|positive|negative/i)[0] rescue nil if kit_type.blank?
      opts.each do |value|

        lot_number = value["Lot number"]
        qty = value["Quantity"].blank? ? "" : value["Quantity"].to_i

        if (!lot_number.blank? && !qty.blank? && qty > 0)
          Inventory.create(lot_no: lot_number,
                           value_numeric: qty,
                           kit_type: kit_type,
                           value_text: kit_text,
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
    @session_date = session[:datetime].to_date rescue Date.today

    @cur_month = @session_date.strftime("%B")
    @cur_year = @session_date.year
    @month_limit = 13
    if (@session_date.year == @session_date.year && @session_date.month == @session_date.month)
      @month_limit = @session_date.month
    end

    @current_location = Location.current_location
    locs = all_htc_facility_locations
    @locations = [["", "All"]] + locs.map { |l| [l.id, l.name] }
    @user = current_user
    users =  User.all
    @users = users.map { |user| [user.username, user.name] rescue nil }.compact

    @kit_names = Kit.all.map(&:name) + ["Negative serum", "Positive serum", "Positive DTS", "Negative DTS"]
    @site_name = settings.facility_name

    @years = []
    i = @session_date.year
    min = User.find_by_sql("SELECT min(date_created) e FROM users LIMIT 1")[0][:e].to_date.year - 1 rescue (Date.today.year - 1)
    while (i >= min)
      @years << i
      i -= 1
    end
    @years.reverse!

    render layout: false
  end

  def kit_loss
    @user = current_user
    @kit_names = Kit.all.map(&:name)
    @session_date = session[:datetime].to_date rescue Date.today

    if request.post?
      captured_data = params[:data] || []
      type = InventoryType.find_by_name("Losses").id

      captured_data.each do |kit_name, opts|
        opts.each do |value|
          lot_number = value["Lot number"]
          qty = value["Quantity"].blank? ? "" : value["Quantity"].to_i
          reason = value["Reason"]

          if (!lot_number.blank? && !qty.blank? && qty > 0 && !reason.blank?)
            CouncillorInventory.create(lot_no: lot_number,
                                       value_numeric: qty,
                                       councillor_id: @user.id,
                                       inventory_type: type,
                                       value_text: ((kit_name.match(/Negative|Positive|positive|negative/i)[0] rescue kit_name) || kit_name),
                                       comments: reason,
                                       encounter_date: @session_date,
                                       voided: false,
                                       creator: current_user.id
            )
          end
        end
      end

      redirect_to '/htcs?tab=admin' and return
    end

    @input_controls = [["Lot number", {"type" => "text"}],
                       ["Quantity", {"type" => "number"}],
                       ["Reason", {"type" => "list"}],
    ]
    @reasons = ['Damaged', 'Other use'];
    render layout: false
  end

  def get_exp_date

    lot_number = params[:lot_number]
    inv_type = params[:type] == "kit" ? "Delivery" : "Serum Delivery"
    result = {td_id: params[:td_id]}
    result["tt"] = inv_type
    date = Inventory.where(inventory_type: InventoryType.where(name: inv_type).first.id,
                           lot_no: lot_number).first.date_of_expiry.strftime("%d %b, %Y") rescue "?"

    result[:out_text] = date || "&nbsp"
    render text: result.to_json
  end

  def quality_control_tests
    @user = current_user
    @location = Location.current_location
    @kits = Kit.where(status: "active")
    sample_type = params[:sample_type]

    kmap = {}
    
    if request.post?
      captured_data = params[:data]
      if !captured_data.blank?
        kmap = {"Serum lot number" => "Serum lot number",
                "Testkit lot number" => "kit lot number",
                "Control line seen" => "Control line seen",
                "Result" => "Quality test result"
        }

        encounter_type = TestEncounterType.where(name: 'Testkit Quality Control').first
        encounter = TestEncounter.create(
            test_encounter_type: encounter_type.id,
            encounter_datetime: (@session_date[:to_date].to_datetime rescue DateTime.now),
            location_id: @location.id,
            creator: @user.id,
            voided: false
        )
      end

      captured_data.each do |key, opts|
        kit_name = key.split(/\-/)[0].strip
        kit_type = key.split(/\-/)[1].scan(/Positive|Negative|positive|negative/i).first.strip

        opts.each do |values|
          values.each do |k, v|
            TestObservation.create(
                encounter_id: encounter.id,
                concept_id: (ConceptName.where(name: kmap[k]).first.concept_id),
                value_text: v,
                obs_datetime: encounter.encounter_datetime,
                location_id: encounter.location_id,
                voided: false
            )
          end
        end
      end
      redirect_to htcs_path and return
    end

    @side_lists = {}

    @serum_types = ["Positive DTS", "Negative DTS"] if sample_type == 'DTS'
    @serum_types = ["Negative serum", "Positive serum" ] if sample_type == 'Serum'
    @input_controls = [["Serum lot number", {"type" => "text"}],
                       ["Testkit lot number", {"type" => "text"}],
                       ["Control line seen", {"type" => "list"}],
                       ["Result", {"type" => "list"}]]

    render layout: false
  end

  def record_temp
    if request.post?
      unless params[:temperature].blank?
        encounter_type = TestEncounterType.where(name: 'Temperature Quality Control').first

        encounter = TestEncounter.create(
            test_encounter_type: encounter_type.id,
            encounter_datetime: (@session_date[:to_date].to_datetime rescue DateTime.now),
            location_id: (Location.current_location).id,
            creator: current_user,
            voided: false
        )

        TestObservation.create(
            encounter_id: encounter.id,
            concept_id: (ConceptName.where(name: 'Temperature').first.concept_id),
            value_numeric: params[:temperature].to_f,
            obs_datetime: encounter.encounter_datetime,
            location_id: encounter.location_id,
            voided: false
        )
      end
      redirect_to htcs_path and return
    end
  end

  def ajax_stock_levels
    result = {}
    user = User.find_by_username(params[:user])
    date = Date.new(params[:year].to_i, params[:month].to_i)
    session_date = (session[:datetime].to_date rescue Date.today)

    i = date.end_of_month
    dates = []
    opening_stock = {}
    closing_stock = {}

    while i >= date.beginning_of_month
      unless i.to_date > session_date
        dates << i.to_date.strftime("%d %B")
        opening_stock[i.strftime("%d %B")] = user.remaining_stock_by_type(params[:kit_name], i.to_date,
                                                             [], "opening", [params[:location].to_i])
        closing_stock[i.strftime("%d %B")] = user.remaining_stock_by_type(params[:kit_name], i.to_date, [],
                                                           "closing", [params[:location].to_i])
      end
      i -= 1.day
    end
    dates.reverse!

    result["dates"] = dates
    result["opening_stock"] = opening_stock
    result["closing_stock"] = closing_stock

    result["receipts"] = user.receipts(params[:kit_name], date.beginning_of_month, date.end_of_month,
                                       [params[:location].to_i])
    result["damaged"] = user.losses(params[:kit_name], date.beginning_of_month, date.end_of_month,
                                   [params[:location].to_i], ["Damaged"])
    result["other_use"] = user.losses(params[:kit_name], date.beginning_of_month, date.end_of_month,
                                           [params[:location].to_i], ["Other use"])
    result["client_tests"] =  user.client_tests(params[:kit_name], date.beginning_of_month, date.end_of_month,
                                          [params[:location].to_i])

    result['totals'] = result.reject{|k, v| k == "dates"}.inject({}){|r, h| r[h[0]] = h[1].values.sum; r}

    render text: result.to_json
  end
end
