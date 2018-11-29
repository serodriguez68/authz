class ClearancesController < ApplicationController
  before_action :set_clearance, only: [:edit, :update, :destroy]

  # GET /clearances
  def index
    @clearances = Clearance.all
  end


  # GET /clearances/new
  def new
    @clearance = Clearance.new
  end

  # GET /clearances/1/edit
  def edit
  end

  # POST /clearances
  def create
    @clearance = Clearance.new(clearance_params)

    if @clearance.save
      redirect_to clearances_url, notice: 'Clearance was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /clearances/1
  def update
    if @clearance.update(clearance_params)
      redirect_to clearances_url, notice: 'Clearance was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /clearances/1
  def destroy
    @clearance.destroy
    redirect_to clearances_url, notice: 'Clearance was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_clearance
      @clearance = Clearance.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def clearance_params
      params.require(:clearance).permit(:level, :name)
    end
end
