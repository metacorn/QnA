class User < ApplicationRecord
  has_many :questions
  has_many :answers
  has_many :badges, dependent: :destroy

  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :rememberable,
          :validatable

  def owner?(content)
    content.user_id == id
  end
end
