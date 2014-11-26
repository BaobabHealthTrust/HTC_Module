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
end
