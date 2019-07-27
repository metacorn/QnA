class OauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    authorize_with('GitHub')
  end

  def vkontakte
    authorize_with('Vkontakte')
  end

  def confirm_email
    user = User.check_email_set_user(params[:oauth_email])
    if user.save
      if authorization = user.create_auth(params[:oauth_email], session[:auth])
        if authorization.init_confirmation
          DeviseConfirmationMailer.oauth_confirmation_instructions(authorization).deliver_now
          redirect_to root_path, notice: "A confirmation email has been sent to #{authorization.oauth_email}."
        end
      else
        flash.now[:alert] = "Error(s) with authentication."
        render 'omniauth_callbacks/confirm_email', locals: {resource: authorization}
      end
    else
      render 'omniauth_callbacks/confirm_email', locals: {resource: user}
    end
  end

  def verify_email
    if authorization = Authorization.find_by(confirmation_token: params[:token])
      authorization.skip_oauth_confirmation!
      redirect_to new_user_session_path, notice: "Your email has been confirmed!"
    else
      redirect_to root_path, alert: "Wrong confirmation token!"
    end
  end

  private

  def authorize_with(provider)
    @user = User.find_for_oauth(auth)
    if @user&.persisted? && current_authorization&.confirmed?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
    elsif @user
      oauth_email_confirmation(provider)
    else
      redirect_to root_path, alert: 'Something was wrong!'
    end
  end

  def oauth_email_confirmation(provider)
    session[:auth] = { uid: auth.uid, provider: auth.provider }
    if current_authorization&.confirmation_sent?
      flash.now[:notice] = "We have already sent you confirmation instructions to #{current_authorization.oauth_email}. Please check your email."
    else
      flash.now[:notice] = "#{provider} did not provide your email. Please enter your email for sending you confirmation instructions."
    end
    render 'omniauth_callbacks/confirm_email'
  end

  def auth
    request.env['omniauth.auth']
  end

  def current_authorization
    @current_authorization ||= @user.authorizations.find_by(provider: auth.provider, uid: auth.uid)
  end
end
