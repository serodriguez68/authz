class CitiesController < ApplicationController
  before_action :set_city, only: [:edit, :update, :destroy]

  # GET /cities
  def index
    authorize skip_scoping: true
    @cities = apply_authz_scopes on: City.all
  end

  # GET /cities/new
  def new
    authorize skip_scoping: true
    @city = City.new
  end

  # GET /cities/1/edit
  def edit
    authorize using: @city
  end

  # POST /cities
  def create

    @city = City.new(city_params)
    authorize using: @city

    if @city.save
      redirect_to cities_url, notice: 'City was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /cities/1
  def update
    @city.assign_attributes(city_params)
    authorize using: @city
    if @city.save
      redirect_to cities_url, notice: 'City was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /cities/1
  def destroy
    authorize using: @city
    @city.destroy
    redirect_to cities_url, notice: 'City was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_city
      @city = City.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def city_params
      params.require(:city).permit(:name)
    end
end
