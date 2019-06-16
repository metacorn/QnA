class Answer < ApplicationRecord
  belongs_to :question

  validates :body,  presence: true,
                    length: { minimum: 50 }
end
