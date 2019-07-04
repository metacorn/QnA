class Question < ApplicationRecord
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable
  has_one :badge, dependent: :destroy

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank
  accepts_nested_attributes_for :badge, reject_if: :all_blank

  default_scope { order(:created_at) }

  validates :title, presence: true,
                    length: { in: 15..75 },
                    uniqueness: { case_sensitive: false }
  validates :body,  presence: true,
                    length: { minimum: 50 }

end
