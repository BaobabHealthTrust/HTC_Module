class ObsController < ApplicationController
  before_action :set_ob, only: [:show, :edit, :update, :destroy]

  # GET /obs
  # GET /obs.json
  def index
    @obs = Ob.all
  end

  # GET /obs/1
  # GET /obs/1.json
  def show
  end

  # GET /obs/new
  def new
    @ob = Ob.new
  end

  # GET /obs/1/edit
  def edit
  end

  # POST /obs
  # POST /obs.json
  def create
    @ob = Ob.new(ob_params)

    respond_to do |format|
      if @ob.save
        format.html { redirect_to @ob, notice: 'Ob was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ob }
      else
        format.html { render action: 'new' }
        format.json { render json: @ob.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /obs/1
  # PATCH/PUT /obs/1.json
  def update
    respond_to do |format|
      if @ob.update(ob_params)
        format.html { redirect_to @ob, notice: 'Ob was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ob.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /obs/1
  # DELETE /obs/1.json
  def destroy
    @ob.destroy
    respond_to do |format|
      format.html { redirect_to obs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ob
      @ob = Ob.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ob_params
      params[:ob]
    end
end
