class AdminsController < ApplicationController
  #before_action :set_admin, only: [:show, :edit, :update, :destroy]


  def index

  end

  def show
  end

  def new

  end 
	
	def protocols
		@protocols = CounselingQuestion.all
		
    @side_panel_data = ""
    sp = ""
   	
   	@protocols.each do |p|
   	
			status = "Active"
			
			if p.retired.to_i == 1
				status = "Deactivated"
			end

			@side_panel_data += sp + "#{p.id} : {
																 	name: '#{p.name}',
																 	status: '#{status}'
																 }"
    	sp = ","   	
   	end
   	
		render layout: false and return
	end
	
	def edit_protocols
		
		@protocol = CounselingQuestion.find(params[:protocol_id])
		@parents = CounselingQuestion.where("child = 0").collect { |p| [p.question_id, p.name]  }
		if request.post?
			raise params.to_yaml
			@protocol.name = params[:name]
			@protocol.retired = @protocol.retired
			@protocol.description = params[:description]
			@protocol.data_type = params[:datatype]
			list = nil
			child = 0
			list = params[:listtype] if ! params[:listtype].blank?
			child = 1 if ! params[:parent].blank?
			@protocol.list_type = list
			@protocol.child = child
			
			if @protocol.save
				raise params[:parent].to_yaml
				if child == 1
					raise params[:parent].to_yaml	
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
			
			if session[:datetime].to_date != Date.today.to_date
				session[:datetime] = DateTime.now
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
			#	raise params.to_yaml
				list = nil
				child = 0
				list = params[:listtype] if ! params[:listtype].blank?
				child = 1 if ! params[:parent].blank?
				@protocol = CounselingQuestion.create(name: params[:name],
										description: params[:description], data_type: params[:datatype],
										retired: 0, creator: current_user.id, list_type: list,
									  child: child)
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
