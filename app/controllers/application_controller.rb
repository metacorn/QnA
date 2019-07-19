class ApplicationController < ActionController::Base
  before_action :set_gon_user

  private

  def set_gon_user
    gon.user_id = current_user ? current_user.id : 0
  end
end
