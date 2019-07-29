class DeviseConfirmationMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'
  default from: 'mailer@qna.com'

  def oauth_confirmation_instructions(authorization)
    @authorization = authorization
    @url = "#{verify_email_url}?token=#{@authorization.confirmation_token}"
    mail(to: @authorization.oauth_email, subject: "Confirm your email for using authentication via #{@authorization.provider}")
  end
end
