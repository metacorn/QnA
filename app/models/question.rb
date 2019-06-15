class Question < ApplicationRecord
  has_many :answers, dependent: :destroy

  validates :title, presence: true,
                    length: { in: 15..75 },
                    uniqueness: { case_sensitive: false }
  validates :body,  presence: true,
                    length: { in: 50..500 }

end
