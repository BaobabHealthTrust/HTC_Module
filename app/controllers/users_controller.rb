class UsersController < ApplicationController
  #before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
 		
		if @user.save
			flash[:notice] = "Welcome to the site!"
			redirect_to "/"
    else
			flash[:alert] = "There was a problem creating your account. Please try again."
			redirect_to :back
    end
  end

  def update

      if @user.update(user_params)

      else

      end

  end

  def destroy
    @user.destroy
  end
	
	private
	
	def user_params
		params.require(:user).permit(:username, :password, :password_confirmation)
	end

end
