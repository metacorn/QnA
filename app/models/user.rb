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
          :omniauthable, omniauth_providers: [:github]

  def self.find_for_oauth(auth)
    Services::FindForOauth.new(auth).call
  end

  def owner?(content)
    content.user_id == id
  end
end
