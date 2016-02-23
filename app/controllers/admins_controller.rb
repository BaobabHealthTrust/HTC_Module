class AdminsController < ApplicationController
  #before_action :set_admin, only: [:show, :edit, :update, :destroy]


  def index

  end

  def show
  end

  def new

  end 

  def tests
    @session_date = session[:datetime].to_date rescue Date.today

    @cur_month = @session_date.strftime("%B")
    @cur_year = @session_date.year

    @user = current_user
    @users = User.find_by_sql("select * from users
                    inner join user_role on users.user_id = user_role.user_id")

    @site_name = settings.facility_name

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

  def new_test
       @kits, @remaining, @testing = Kit.kits_available(current_user)
      # raise @kits[0][1].to_yaml
      @tests = ["Test 1", "Test 2", "Test 3", "Final Result"]
  end

	def protocols
		@protocols = CounselingQuestion.all		
    @side_panel_data = generate_protocols_javascript_hash(@protocols)
		render layout: false and return
	end
	
	def edit_protocols
		
		@protocol = CounselingQuestion.find(params[:protocol_id])
		@parents = CounselingQuestion.where("child = 0").collect { |p| [p.question_id, p.name]  }
		if request.post?
			@protocol.name = params[:name]
			@protocol.retired = @protocol.retired
			@protocol.description = params[:description]
			@protocol.data_type = params[:datatype]
      @protocol.date_updated = Date.today
			list = nil
			child = 0
			list = params[:listtype] if ! params[:listtype].blank?
			child = 1 if ! params[:parent_protocol].blank?
			@protocol.list_type = list
			@protocol.child = child
      
			if @protocol.save
				if child == 1
					@children = ChildProtocol.create(protocol_id: @protocol.id,
            parent_id: params[:parent_protocol])
				end
				redirect_to protocols_path and return
			end
		elsif ! params[:retire].blank?
			@protocol.retired = params[:retire].to_i
			if @protocol.save
				redirect_to protocols_path and return
				
			end
		end
    @location = Location.all.limit(20)
	end
  
  def set_date
			
			if !session[:datetime].blank?
				session[:datetime] = nil
					if ! params[:client_id].blank?
							redirect_to "/clients/#{params[:client_id]}" and return
					else
							redirect_to htcs_path and return
					end
			end
			if request.post?
				session[:datetime] = params[:dates]
				if ! params[:client_id].blank?
						redirect_to "/clients/#{params[:client_id]}" and return
				else
						redirect_to htcs_path and return
				end
			end
			
	end
  
	def new_protocol
    @protocols = CounselingQuestion.all.collect { |p| [p.question_id, p.name]  }
			if !params[:new_protocol].blank?
				return
			elsif request.post?
				list = nil
				child = 0
				list = params[:listtype] if ! params[:listtype].blank?
				child = 1 if ! params[:parent_protocol].blank?
				@protocol = CounselingQuestion.create(name: params[:name],
										description: params[:description], data_type: params[:datatype],
										retired: 0, creator: current_user.id, list_type: list,
									  child: child, date_created: Date.today)
        if child == 1
         # raise params[:parent].to_yaml
					@children = ChildProtocol.create(protocol_id: @protocol.id,
            parent_id: params[:parent_protocol])
				end
				redirect_to protocols_path and return
			end
	end

  def edit
  end

  def create
    @admin = Admin.new(admin_params)
      if @admin.save
      else
      end

  end

  def update
      if @admin.update(admin_params)

      else

      end
  end

  def destroy
    @admin.destroy
  end
  
	def generate_protocols_javascript_hash(protocols)
	
    side_panel_data = ""
    sp = ""
   	
   	protocols.each do |p|
   	
			status = "Active"
			
			if p.retired.to_i == 1
				status = "Deactivated"
			end

			position = 0
			position = p.position if !p.position.blank?
			side_panel_data += sp + "#{p.id} : {name: '#{p.name}', status: '#{status}',position: '#{position}'}"
    	sp = ","   	
   	end
   	side_panel_data = "{}" if side_panel_data.blank?
		side_panel_data
	end
  
  def update_protocol_position
  	@result = false
  	
  	protocol = CounselingQuestion.find(params[:id])
  	protocol.position = params[:position].to_i
  	
  	@result = protocol.save
  	
		@protocols = CounselingQuestion.all		
    @side_panel_data = generate_protocols_javascript_hash(@protocols);
  	
  	render text: %Q(#{@result};"{#{@side_panel_data}}")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin
      @admin = Admin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_params
      params[:admin]
    end
end
