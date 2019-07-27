class Authorization < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true,
                  uniqueness: { scope: :provider, message: 'authentication with these provider and uid is already in use' }
  validates :oauth_email, presence: true,
                          uniqueness: { scope: :provider, message: 'authentication with these provider and e-mail is already in use' }
  validates_format_of :oauth_email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  def confirmed?
    self.confirmed_at? ? true : false
  end

  def confirmation_sent?
    self.confirmation_sent_at? ? true : false
  end

  def skip_oauth_confirmation!
    update!(confirmed_at: Time.now)
  end

  def init_confirmation
    confirmation_token = Devise.friendly_token[0, 20]
    update(confirmation_token: confirmation_token, confirmation_sent_at: Time.now) ? true : false
  end
end
