class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question

  validates :body,  presence: true,
                    length: { minimum: 50 }

  default_scope { order :created_at }
end
