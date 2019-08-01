class ApplicationController < ActionController::Base
  before_action :set_gon_user

  check_authorization unless: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_url, alert: exception.message }
      format.json { head :forbidden }
      format.js { head :forbidden }
    end
  end

  private

  def set_gon_user
    gon.user_id = current_user ? current_user.id : 0
  end
end
