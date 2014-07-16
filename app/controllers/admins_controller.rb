class AdminsController < ApplicationController
  #before_action :set_admin, only: [:show, :edit, :update, :destroy]


  def index

  end

  def show
  end

  def new

  end 
	
	def protocols
		@protocols = CounselingQuestion.where("retired = 0")	
	end
	
	def edit_protocols
		@protocol = CounselingQuestion.find(params[:protocol_id])
		if request.post?
			@protocol.name = params[:name]
			@protocol.retired = params[:retired]
			@protocol.description = params[:description]
			if @protocol.save
				redirect_to protocols_path
			end
		end
	end
  
	def new_protocol
			if request.post?
				@protocol = CounselingQuestion.create(name: params[:name],
										description: params[:description], retired: 0, 
										creator: current_user.id)
				redirect_to protocols_path
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
