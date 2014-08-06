class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update]

  def index
    @users = User.unscoped.all
    render layout: false
  end

  def show
  end

  def new
    @user = User.new
    #render layout: false
  end

  def edit
  	@user = User.unscoped.find(params[:id])
  end

  def create
  	User.current_user_id = session[:user_id];
  	person = Person.create(person_params)

  	params[:name][:person_id] = person.id
  	params[:user][:person_id] = person.id
  	
    name = PersonName.create(name_params)
 
    @user = User.new(user_params) 		
		if @user.save
			flash[:notice] = "Welcome to the site!"
			redirect_to users_path and return
    else
			flash[:alert] = "There was a problem creating your account. Please try again."
			redirect_to :back and return
    end
  end

  def update

      if @user.update(user_params)
					redirect_to users_path
      else

      end
  end

  def destroy
  	@user = User.unscoped.find(params[:id])
    @user.destroy rescue flash[:alert] = "Failed to delete: Foreign key constraint issue"
    redirect_to users_path and return 
  end
  
  def retire
  	@user = User.unscoped.find(params[:id])
  	@user.retired = params[:retire]
  	@user.save rescue flash[:alert] = "Error: retire value cannot be updated"
  	redirect_to users_path and return
  end
  
	
	private

  def set_user
    @user = User.find(params[:id])
  end

	def person_params
		params.require(:person).permit(:gender, :birthdate)
	end

	def user_params
		params.require(:user).permit(:person_id,:username, :password)
	end

	def name_params
		params.require(:name).permit(:person_id, :given_name, :family_name)
	end
end
