class ApplicationController < ActionController::Base
  before_action :set_gon_user

  private

  def set_gon_user
    gon.user_id = current_user.id if current_user
  end
end
