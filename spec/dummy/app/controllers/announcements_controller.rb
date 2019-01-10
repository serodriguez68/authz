class AnnouncementsController < ApplicationController
  def index
    authorize skip_scoping: true
    @announcements = apply_authz_scopes(on: Announcement).distinct
  end

  def new
    authorize skip_scoping: true
    @announcement = Announcement.new
    @cities = City.all
  end

  def create
    cities = apply_authz_scopes(on: City).where(id: params[:city_ids])
    @announcement = Announcement.new(announcement_params)
    @announcement.cities << cities
    authorize using: @announcement

    if @announcement.save
      redirect_to announcements_url, notice: 'Announcement was successfully created.'
    else
      render :new
    end
  end

  def destroy
    ann = Announcement.find params[:id]
    authorize using: ann
    ann.destroy
    redirect_to announcements_url, notice: 'Announcement was successfully destroyed.'
  end

  private

  def announcement_params
    params.require(:announcement).permit(:body)
  end
end
