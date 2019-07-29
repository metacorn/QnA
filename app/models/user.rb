class User < ApplicationRecord
  has_many :questions
  has_many :answers
  has_many :comments
  has_many :badges, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :authorizations, dependent: :destroy

  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :rememberable,
          :validatable,
          :confirmable,
          :omniauthable, omniauth_providers: [:github, :vkontakte]

  validates_format_of :email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  class << self
    def find_for_oauth(auth)
      Services::FindForOauth.new(auth).call
    end

    def check_email_set_user(email)
      user = User.find_or_initialize_by(email: email) do |user|
        password = Devise.friendly_token[0, 20]
        user.email = email
        user.password = password
        user.password_confirmation = password
        user.skip_confirmation!
      end
      user
    end
  end

  def create_auth(mail, session_auth)
    authorizations.create(oauth_email: mail,
                          provider: session_auth["provider"],
                          uid: session_auth["uid"])
  end

  def owner?(content)
    content.user_id == id
  end
end
