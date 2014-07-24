class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  def index
    htc_tags = LocationTag.where("name LIKE '%HTC%'").map(&:location_tag_id)
    @locations = Location.joins(:location_tag_maps)
                          .where(:location_tag_map => {:location_tag_id => htc_tags})
  end

  def show
  
  end

  def new
    @location = Location.new
    @location_tags = LocationTag.all.map{|l| [l.name, l.id]}
  end

  def edit
  end

  def create
      loc_params = {                                                     
                    :name => params[:name],                             
                    :description => params[:description]                
                   }
       
    @location_tag_id = params[:location_tag]
    @location = Location.new(loc_params)
    if @location.save
    	location_tag_map_params = {
    															:location_id => @location.id,
    															:location_tag_id => @location_tag_id
    														}
			@location_tag_map = LocationTagMap.create(location_tag_map_params)
			if @location_tag_map.save
			 flash[:notice] = "Location: #{@location.name} successfully created"
       redirect_to locations_path 
      else
			 flash[:alert] = "Failed to created Location: #{location_params[:name]}"
       redirect_to locations_path 
      end
    else

    end

  end

  def update
    if @location.update(location_params.permit(:name))
      flash[:notice] = "Update  successful"      
      redirect_to locations_path 
    else
      flash[:alert] = "Failed to created Location: #{location_params[:name]}"  
      redirect_to locations_path
    end
  end

  def destroy
    name = @location.name
    @location.destroy
    flash[:alert] = "#{name} successfuly deleted"  
    redirect_to locations_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list 
    # through.

    def location_params
      params[:location]
    end
end
