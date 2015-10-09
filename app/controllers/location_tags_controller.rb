class LocationTagsController < ApplicationController
  before_action :set_location_tag, only: [:show, :edit, :update, :destroy]


  def index
    @location_tags = LocationTag.all
  end


  def show
  end


  def new
    @location_tag = LocationTag.new
  end


  def edit
  end

  def create
    @location_tag = LocationTag.new(location_tag_params)

    if @location_tag.save
    else
    end
  end

  def update
    if @location_tag.update(location_tag_params)
    else
    end
  end

  def destroy
    @location_tag.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location_tag
      @location_tag = LocationTag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_tag_params
      params[:location_tag]
    end
end
