class RatingsController < ApplicationController

  def index
    authorize skip_scoping: true
    @ratings = apply_authz_scopes(on: Rating)
               .includes(:user, :city, :report)
               .order('cities.name ASC, reports.id ASC')
  end

  def new
    @report = Report.find params[:report_id]
    authorize using: @report
    @rating = Rating.new user: current_user, report: @report
  end

  def create
    @rating = Rating.new(rating_params)
    @rating.user = current_user
    authorize using: @rating

    if @rating.save
      redirect_to @rating.report, notice: 'Rating was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @rating = Rating.find params[:id]
    authorize using: @rating
    @rating.destroy
    redirect_to ratings_url, notice: 'Rating was successfully destroyed.'
  end

  private
  # Only allow a trusted parameter "white list" through.
  def rating_params
    params.require(:rating).permit(:score, :report_id)
  end

end
