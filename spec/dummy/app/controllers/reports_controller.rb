class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :edit, :update, :destroy]

  # GET /reports
  def index
    authorize skip_scoping: true
    @reports = apply_authz_scopes(on: Report)
               .includes(:user, :city, :clearance)
               .order('cities.name ASC')
  end

  # GET /reports/1
  def show
    authorize using: @report
  end

  # GET /reports/new
  def new
    authorize skip_scoping: true
    @report = Report.new
  end

  # GET /reports/1/edit
  def edit
    authorize using: @report
  end

  # POST /reports
  def create
    @report = Report.new(report_params)
    @report.user = current_user
    authorize using: @report

    if @report.save
      redirect_to @report, notice: 'Report was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /reports/1
  def update
    @report.assign_attributes(report_params)
    authorize using: @report
    if @report.save
      redirect_to @report, notice: 'Report was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /reports/1
  def destroy
    authorize using: @report
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
