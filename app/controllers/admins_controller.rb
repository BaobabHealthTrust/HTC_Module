class AdminsController < ApplicationController
  before_action :set_admin, only: [:show, :edit, :update, :destroy]


  def index
    @admins = Admin.all
  end

  def show
  end

  def new

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
