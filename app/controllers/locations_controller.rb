class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  def index
    locations = all_htc_facility_locations
    
    @locations = {}
    @side_panel_data = ""
    sp = ""
   	
   	locations.each do |l|
   		tag_id = LocationTagMap.where("location_id = #{l.id}").first.location_tag_id
   		location_tag = LocationTag.find(tag_id).name
   		name = l.name.humanize
   		@locations[l.id] = {name: name, description: location_tag}
   		
			@side_panel_data += sp + "#{l.id} : {
																 	name: '#{l.name.humanize}',
																 	description: '#{location_tag}'
																 }"
    	sp = ","   	
   	end
   	
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
  	rooms = all_htc_facility_locations.map{|r| r.name.humanize}
  	redirect_to locations_path and return if rooms.include?(params[:name].humanize)
    
    loc_params = {                                                     
                  :name => params[:name],                             
                  :description => params[:description],
									:creator => current_user.id                
                 }
       
    @location_tag_id = params[:location_tag]
    @location = Location.new(loc_params)
    @location.id = Location.last.id + 1
    
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

	def village
			location = District.where("name LIKE '%#{params[:search]}%'")
			location = location.map do |locs|
      "#{locs.name}"
    end
    render :text => location.join("\n") and return
	end

   def ta
      #return if params[:search].blank?
			# location = TraditionalAuthority.where("name LIKE '%#{params[:search]}%'")
      location = District.find_by_sql("SELECT d.name as district_name, ta.name as ta_name
      FROM district d
      Inner join traditional_authority ta
      on d.district_id = ta.district_id 
      where d.name LIKE  '%#{params[:district]}%'")
      location = location.map do |locs|
      "#{locs.ta_name}"
    end
    render :text => location.join("\n") and return
	end

	def print
		location = Location.find(params[:id])
		print_string = get_location_label(location)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:id]}#{rand(10000)}.lbl", :disposition => "inline")
		#redirect_to '/locations'
	end
	
	def get_location_label(location)
    return unless location.location_id
    location_name = location.name

    label = "\nN
q801
Q329,026
ZT
B50,180,0,1,5,15,120,N,'#{location_name}'
A35,30,0,2,2,2,N,'#{location_name}'
P1\n"
    label
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
