class OauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    # render json: request.env['omniauth.auth']
    @user = User.find_for_oauth(request.env['omniauth.auth'])
    if @user&.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'GitHub') if is_navigational_format?
    else
      redirect_to root_path, alert: 'Something went wrong!'
    end
  end
end
