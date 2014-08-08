class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  def index
    htc_tags = LocationTag.where("name LIKE '%HTC%'").map(&:location_tag_id)
    @locations = Location.joins(:location_tag_maps)
                          .where(:location_tag_map => {:location_tag_id => htc_tags})
    render :layout => false
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
                    :description => params[:description],
										:creator => current_user.id                
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
    @alert=nil
    name = @location.name
    
    @location.destroy rescue @alert="Cannot delete location"
    flash[:alert] = "#{name} successfuly deleted" if @alert.nil?
    
    redirect_to '/locations'
  end

	def print
		location = Location.find(params[:id])
		print_string = get_location_label(location)
		redirect_to '/locations'
	end
	
	def get_location_label(location)
    return unless location.location_id
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false,"#{location.location_id}")
    label.draw_multi_text("#{location.name}")
    label.print(1)
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
