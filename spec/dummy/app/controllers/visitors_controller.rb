class VisitorsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  def index
  end

  def after_login
  end
end
