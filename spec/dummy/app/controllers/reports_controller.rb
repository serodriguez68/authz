class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :edit, :update, :destroy]

  # GET /reports
  def index
    @reports = Report.all.includes(:user, :city, :clearance)
    authorize
  end

  # GET /reports/1
  def show
    authorize
  end

  # GET /reports/new
  def new
    @report = Report.new
    authorize
  end

  # GET /reports/1/edit
  def edit
    authorize
  end

  # POST /reports
  def create
    @report = Report.new(report_params)
    authorize
    @report.user = current_user

    if @report.save
      redirect_to @report, notice: 'Report was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /reports/1
  def update
    authorize
    if @report.update(report_params)
      redirect_to @report, notice: 'Report was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /reports/1
  def destroy
    authorize
    @report.destroy
    redirect_to reports_url, notice: 'Report was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def report_params
      params.require(:report).permit(:clearance_id, :city_id, :title, :body)
    end
end
