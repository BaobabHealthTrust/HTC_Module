class ReportsController < ApplicationController
  def index
  end

  def moh_report
    @session_date = session[:datetime].to_date rescue Date.today
    @cur_month = @session_date.strftime("%B")[0,3]
    @cur_year = @session_date.year

    @user = current_user
    @users = User.find_by_sql("select * from users
                    inner join user_role on users.user_id = user_role.user_id")

    @site_name = Settings.facility_name

    @years = []
    i = @session_date.year
    min = User.find_by_sql("SELECT min(date_created) e FROM users LIMIT 1")[0][:e].to_date.year - 1  rescue (Date.today.year - 1)
    while (i >= min)
 	    @years << i
	    i -= 1
    end
    @years.reverse!

    render layout: false
  end

  def mohquartery_report
    @session_date = session[:datetime].to_date rescue Date.today
    @cur_month = @session_date.strftime("%B")[0,3]
    @cur_year = @session_date.year

    @user = current_user
    @users = User.find_by_sql("select * from users
                    inner join user_role on users.user_id = user_role.user_id")

    @site_name = Settings.facility_name

    @years = []
    i = @session_date.year
    min = User.find_by_sql("SELECT min(date_created) e FROM users LIMIT 1")[0][:e].to_date.year - 1  rescue (Date.today.year - 1)
    while (i >= min)
      @years << i
      i -= 1
    end
    @years.reverse!

    render layout: false
  end
  
  def monthly_report
    @session_date = session[:datetime].to_date rescue Date.today
    @cur_month = @session_date.strftime("%B")[0,3]
    @cur_year = @session_date.year

    @user = current_user
    @users = User.find_by_sql("select * from users
                    inner join user_role on users.user_id = user_role.user_id")

    @site_name = Settings.facility_name

    @years = []
    i = @session_date.year
    min = User.find_by_sql("SELECT min(date_created) e FROM users LIMIT 1")[0][:e].to_date.year - 1  rescue (Date.today.year - 1)
    while (i >= min)
 	    @years << i
	    i -= 1
    end
    @years.reverse!

    render layout: false
  end

  def stock_report
		@session_date = session[:datetime].to_date rescue Date.today
		@start_date = Inventory.first.encounter_date.to_date rescue Date.today
		@cur_month = @session_date.strftime("%B")
		@cur_year = @session_date.year
		@start_month = @start_date.strftime("%B")
		@start_year = @start_date.year
		@month_limit = 13
		if (@session_date.year == @session_date.year && @session_date.month == @session_date.month)
      @month_limit = @session_date.month
		end
		@current_location = Location.current_location
		locs = all_htc_facility_locations
		@locations = [["", "All"]] + locs.map { |l| [l.id, l.name] }
		@user = current_user
		users = User.all
		@users = users.map { |user| [user.username, user.name] rescue nil }.compact
		@kit_names = Kit.all.map(&:name) + ["All(Kits)", "Positive Serum", "Negative Serum", "All(Serum)"]
		@site_name = Settings.facility_name
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

  def ajax_stock_levels_report
		result = {}
		result['totals'] = {}
		result['totals']["receipts"] = 0
		result['totals']["damages"] = 0
		result['totals']["distribution"] = 0
		result['totals']["remaining"] = 0
		user = User.find_by_username(params[:user])
		start_date = Date.new(params[:year1].to_i, params[:month1].to_i, params[:day1].to_i)
		end_date = Date.new(params[:year2].to_i, params[:month2].to_i, params[:day2].to_i)
		session_date = (session[:datetime].to_date rescue Date.today)
		kits = ""
    
		case params[:kit_name]
		when '' || nil
      kits = ""
		when "All(Kits)"
      kits = ["Determine", "UniGold"]
		when "All(Serum)"
      kits = ["Positive", "Negative"]
		else
      kits = [params[:kit_name].gsub(/Serum/i, "").strip]
		end
		receipts = Inventory.transaction_sums(kits, ["Delivery", "Serum Delivery"], start_date, end_date)
		losses = Inventory.transaction_sums(kits, ["Losses"], start_date, end_date)

		distributed = CouncillorInventory.transaction_sums(kits, ["Distribution"], start_date, end_date)
		receipts.each do |r|
      type = Kit.find(r.type).name rescue r.type
      result[r.date.to_date.strftime("%d %b, %Y")] = {} if result[r.date.to_date.strftime("%d %b, %Y")].blank?
      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no] = {} if result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no].blank?
      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type] = {} if result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type].blank?
      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["receipts"] = r.total
      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["exp_date"] = r.exp_date.strftime("%d %b, %Y") unless r.exp_date.blank?
      if result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["remaining"].blank?
        result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["remaining"] = Inventory.remaining_sum(r.date.to_date, r.lot_no, type)
        result['totals']["remaining"] += result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["remaining"].to_i
      end
      result['totals']["receipts"] += r.total.to_i
		end

		losses.each do |r|
      type = Kit.find(r.type).name rescue r.type
      result[r.date.to_date.strftime("%d %b, %Y")] = {} if result[r.date.to_date.strftime("%d %b, %Y")].blank?
      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no] = {} if result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no].blank?
      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type] = {} if result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type].blank?
      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["damages"] = r.total
      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["exp_date"] = r.exp_date.strftime("%d %b, %Y") unless r.exp_date.blank?

      if result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["remaining"].blank?
        result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["remaining"] = Inventory.remaining_sum(r.date.to_date, r.lot_no, type)
        result['totals']["remaining"] += result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["remaining"].to_i
      end
      result['totals']["damages"] += r.total.to_i
		end

    distributed.each do |r|
      type = Kit.find(r.type).name rescue r.type
      result[r.date.to_date.strftime("%d %b, %Y")] = {} if result[r.date.to_date.strftime("%d %b, %Y")].blank?
      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no] = {} if result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no].blank?
      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type] = {} if result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type].blank?
      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["distribution"] = r.total

      result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["exp_date"] = r.exp_date.strftime("%d %b, %Y")   unless r.exp_date.blank?

      if result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["remaining"].blank?
        result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["remaining"] = Inventory.remaining_sum(r.date.to_date, r.lot_no, type)
        result['totals']["remaining"] += result[r.date.to_date.strftime("%d %b, %Y")][r.lot_no][type]["remaining"].to_i
      end
      result['totals']["distribution"] += r.total.to_i
    end

    result['dates'] = result.reject { |r, v| r == "totals" }.keys.sort
    render text: result.to_json
  end

  def temp_changes
    @session_date = session[:datetime].to_date rescue Date.today
    render layout: false
  end

  def ajax_temp_changes
    @session_date = session[:datetime].to_date rescue Date.today

    start_date = TestObservation.where("obs_datetime = (SELECT MIN(obs_datetime)
									 FROM test_observation)").first.obs_datetime rescue Date.today

    end_date = TestObservation.where("obs_datetime = (SELECT MAX(obs_datetime)
									 FROM test_observation)").first.obs_datetime rescue Date.today

    data = TestEncounter.temperatures(start_date, end_date)
    @result = {}

    data.each do |d|
      @result[d.obs_datetime.strftime("%Y-%m-%d-%H-%M-%S")] = d.value_numeric
    end
    render layout: true
  end
end