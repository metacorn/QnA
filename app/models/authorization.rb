class Authorization < ApplicationRecord
  belongs_to :user, dependent: :destroy

  validates :provider, presence: true
  validates :uid, presence: true
end
